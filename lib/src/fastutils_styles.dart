// FastUtils is an util package designed to speed up flutter development
// Copyright (C) 2026  WoLKaR-dev
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:ui';
import 'package:fastutils/fastutils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Color pallete privado
final _colorPalette = FastUtils().colorPalette;

/// Fondo de la pantalla de las apps
class Background extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;
  final Color? color;
  final bool? legible;

  const Background({
    super.key,
    this.padding,
    required this.child,
    this.color,
    this.legible = true,
  });

  @override
  Widget build(BuildContext context) {
    //ATOMS Legible content
    final content = legible!
        ? Align(
            alignment: AlignmentGeometry.topCenter,
            child: Legible(child: child),
          )
        : child;

    return Container(
      padding: padding ?? EdgeInsets.all(15),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(color: color ?? _colorPalette.surface),
      child: SafeArea(child: content),
    );
  }

  Widget aligned({AlignmentGeometry? alignment = Alignment.topCenter}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding ?? EdgeInsets.all(15),
      decoration: BoxDecoration(color: _colorPalette.surface),
      child: SafeArea(
        child: Align(alignment: alignment!, child: child),
      ),
    );
  }
}

/// Pantallas deslizables de la app
class Scroll extends StatefulWidget {
  final Axis scrollDirection;
  final List<Widget> children;
  final EdgeInsets? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool lockScroll;
  final bool draggable;

  const Scroll({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.scrollDirection = Axis.vertical,
    this.lockScroll = false,
    this.draggable = false,
  });

  /// Devuelve un Scroll adaptado SOLO para un [BottomSheet]
  Widget bottomSheet() {
    return Scroll(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 50),
      children: children,
    );
  }

  /// Adds more children to a scroll widget
  Widget addChildren(List<Widget> newChildren) {
    return Scroll(children: [...children, ...newChildren]);
  }

  @override
  State<Scroll> createState() => _ScrollState();
}

class _ScrollState extends State<Scroll> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //ATOMS Scroll principal
    Widget scroll = SingleChildScrollView(
      controller: scrollController,
      physics: widget.lockScroll ? NeverScrollableScrollPhysics() : null,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      child: widget.scrollDirection == Axis.vertical
          ? Column(
              spacing: widget.spacing,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: widget.children,
            )
          : Row(
              spacing: widget.spacing,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: widget.children,
            ),
    );

    //ATOMS Scroll con scroll horizontal
    if (widget.scrollDirection == Axis.horizontal) {
      scroll = Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            final double delta = signal.scrollDelta.dy;
            final double newOffset = scrollController.offset + delta;
            if (scrollController.hasClients) {
              scrollController.jumpTo(
                newOffset.clamp(0.0, scrollController.position.maxScrollExtent),
              );
            }
          }
        },
        child: scroll,
      );
    }

    //LAYOUT Definicion final
    return widget.draggable
        ? ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            child: scroll,
          )
        : scroll;
  }
}

/// Input de textfield de la app
class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.controller,
    this.onChange,
    this.obscure = false,
    this.hintText = "",
    this.dialog = false,
    this.textInputType = TextInputType.text,
    this.centered = false,
    this.initiallySelected = false,
    this.onLeave,
    this.onSubmitted,
    this.focusNode,
  });

  final dynamic onChange;
  final bool obscure;
  final String hintText;
  final TextEditingController controller;
  final bool? dialog;
  final TextInputType? textInputType;
  final bool initiallySelected;
  final bool centered;
  final Function(String)? onLeave;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: switch (FastUtils().screenSize) {
        ScreenSize.small ||
        ScreenSize.regular => MediaQuery.sizeOf(context).width * 0.9,
        ScreenSize.large => MediaQuery.sizeOf(context).width * 0.60,
        ScreenSize.xlarge || ScreenSize.xxlarge =>
          !dialog!
              ? MediaQuery.sizeOf(context).width * 0.30
              : MediaQuery.sizeOf(context).width * 0.15,
      },
      child: TextField(
        focusNode: focusNode,
        onTapOutside: (event) {
          onLeave?.call(controller.text);
        },
        onSubmitted: onSubmitted ?? (value) {},
        selectAllOnFocus: initiallySelected,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        keyboardType: textInputType,
        onChanged: (value) {
          if (onChange != null) {
            onChange(value);
          }
        },
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: _colorPalette.secondaryContainer,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: _colorPalette.outline),
            borderRadius: BorderRadius.circular(360),
          ),
        ),
      ),
    );
  }

  Widget simple({
    bool? limitedLines = true,
    int? lineLimit = 1,
    bool? restricted = false,
  }) {
    return Builder(
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: Colors.black12,
            ),
          ),
          child: SizedBox(
            width: restricted!
                ? switch (FastUtils().screenSize) {
                    ScreenSize.small || ScreenSize.regular =>
                      MediaQuery.sizeOf(context).width * 0.9,
                    ScreenSize.large => MediaQuery.sizeOf(context).width * 0.60,
                    ScreenSize.xlarge || ScreenSize.xxlarge =>
                      !dialog!
                          ? MediaQuery.sizeOf(context).width * 0.30
                          : MediaQuery.sizeOf(context).width * 0.15,
                  }
                : null,
            child: TextField(
              focusNode: focusNode,
              onSubmitted: onSubmitted ?? (value) {},
              cursorColor: Colors.black12,
              maxLines: limitedLines! ? lineLimit : null,
              onChanged: (value) {
                if (onChange != null) {
                  onChange(value);
                }
              },
              controller: controller,
              obscureText: obscure,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black12,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: _colorPalette.outline),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: _colorPalette.outline),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Indicador de disponibilidad
class AvailabilityIndicator extends StatelessWidget {
  final bool available;
  final String? availableText;
  final String? unavailableText;

  const AvailabilityIndicator({
    super.key,
    required this.available,
    this.availableText = "Available__",
    this.unavailableText = "Unavailable__",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        border: Border.all(
          color: available ? Colors.green[900]! : Colors.red[900]!,
          width: 2,
        ),
        color: available ? Colors.green[100] : Colors.red[100],
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            available ? Icons.check : Icons.close,
            color: available ? Colors.green[900] : Colors.red[900],
          ),
          Text(
            available ? availableText! : unavailableText!,
            style: TextStyle(
              fontSize: switch (FastUtils().screenSize) {
                ScreenSize.small || ScreenSize.regular => 18,
                ScreenSize.large ||
                ScreenSize.xlarge ||
                ScreenSize.xxlarge => 20,
              },
              color: available ? Colors.green[900] : Colors.red[900],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón que permite estar activo segun toggle
///
/// [active] define si está activo o no. [text] debe proveer el texto para mostrar en el
/// botón y [onToggle] se retornará el inverso del valor actual del botón
class ToggleableTextButton extends StatelessWidget {
  final String baseText;
  final String? unselectedText;
  final String? selectedText;
  final double? width;
  final bool? circle;
  final bool active;
  final Function(bool) onToggle;

  const ToggleableTextButton({
    super.key,
    required this.active,
    required this.baseText,
    required this.onToggle,
    String? unselectedText,
    String? selectedText,
    this.circle = true,
    this.width,
  }) : selectedText = selectedText ?? baseText,
       unselectedText = unselectedText ?? baseText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onToggle(!active);
      },
      child: Container(
        width: width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? Colors.black : _colorPalette.outline,
          ),
          color: active
              ? _colorPalette.secondaryContainer
              : _colorPalette.surfaceContainer,
          shape: circle! ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: Center(
          child: Text(active ? selectedText! : unselectedText!).p(
            color: active
                ? _colorPalette.onSecondaryContainer
                : _colorPalette.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Botón que forma parte de un [BottomSheet]
///
/// [icon] como icono y [text] como texto del botón. [onTap] como callback a ejecutar al ser
/// presionado.
/// [color] como color opcional del icono y texto. [rounded] representa opcionalmente si redondear
/// el tile.
class BottomSheetListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final bool? rounded;

  const BottomSheetListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
    this.rounded = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text).h6(),
      iconColor: color,
      textColor: color,
      onTap: onTap,
      leading: Icon(icon),
      shape: rounded!
          ? RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(360),
            )
          : null,
    );
  }
}

/// Restricts the horizontal size to make content legible
class Legible extends StatelessWidget {
  const Legible({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: switch (FastUtils().screenSize) {
        ScreenSize.small ||
        ScreenSize.regular => MediaQuery.sizeOf(context).width,
        ScreenSize.large => MediaQuery.sizeOf(context).width * 0.7,
        ScreenSize.xlarge => MediaQuery.sizeOf(context).width * 0.4,
        ScreenSize.xxlarge => MediaQuery.sizeOf(context).width * 0.3,
      },
      child: child,
    );
  }
}

//STYLE Carta grande inicio
class HomeBigCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final dynamic onPressed;
  final LinearGradient? gradient;
  final BoxFit? fit;

  const HomeBigCard(
    this.title,
    this.description,
    this.image, {
    super.key,
    this.onPressed,
    this.gradient,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onPressed ?? () {},
        child: Container(
          width: switch (FastUtils().screenSize) {
            ScreenSize.small ||
            ScreenSize.regular => MediaQuery.sizeOf(context).width * 0.9,
            ScreenSize.large => MediaQuery.sizeOf(context).width * 0.6,
            ScreenSize.xxlarge ||
            ScreenSize.xlarge => MediaQuery.sizeOf(context).width * 0.4,
          },
          decoration: BoxDecoration(
            color: _colorPalette.surfaceContainer,
            border: Border.all(color: _colorPalette.outline),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      color: gradient != null
                          ? null
                          : _colorPalette.surfaceContainer,
                    ),
                    child: Image.asset(image, fit: fit ?? BoxFit.cover),
                  ),
                ),
              ),

              Text(title).h4(bold: true),
              Text(description).h5(),
            ],
          ),
        ),
      ),
    );
  }
}

//STYLE Carta pequeña inicio
class HomeSmallCard extends StatelessWidget {
  final String description;
  final dynamic onPressed;
  final String? image;
  final LinearGradient? gradient;

  const HomeSmallCard({
    super.key,
    required this.description,
    this.image,
    this.onPressed,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onPressed ?? () {},
        child: Container(
          width: switch (FastUtils().screenSize) {
            ScreenSize.small ||
            ScreenSize.regular => MediaQuery.sizeOf(context).width * 0.9,
            ScreenSize.large => MediaQuery.sizeOf(context).width * 0.6,
            ScreenSize.xxlarge ||
            ScreenSize.xlarge => MediaQuery.sizeOf(context).width * 0.4,
          },
          decoration: BoxDecoration(
            color: _colorPalette.surfaceContainer,
            border: Border.all(color: _colorPalette.outline),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            spacing: 10,
            children: [
              SizedBox.square(
                dimension: 75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      color: gradient != null
                          ? null
                          : _colorPalette.surfaceContainer,
                    ),
                    child: Image.asset(
                      image ?? "assets/icons/icon.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(child: Text(description).h5()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialogo de confirmación de eliminación
///
/// Ejemplo de implementación:
/// ```dart
/// () async {
///   final result = await showDialog(DeleteDialog());
///   if (result) {
///     //gestionar eliminación
///   }
/// }
/// ```
///
/// Retorna `true` si se ha confirmado la eliminación o `false` si no.
class DeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String delete;
  final String cancel;

  const DeleteDialog({
    super.key,
    this.title = "Confirmar eliminación",
    this.content =
        "¿Seguro que quieres eliminar el contenido? Esta acción no es reversible",
    this.delete = "Eliminar",
    this.cancel = "Cancelar",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Scroll(children: [Text(content).p()]),
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context, false);
          },
          label: Text(cancel),
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorPalette.primary,
            foregroundColor: _colorPalette.onPrimary,
          ),
          icon: Icon(Icons.close),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context, true);
          },
          label: Text(delete),
          icon: Icon(Icons.delete_forever),
        ),
      ],
    ).constrained(context);
  }
}

/// Dialogo de renombrado
///
/// [title] como el titulo, [content] como el contenido antes del input,
/// [rename] como botón de aceptado, [cancel] como cancelación. [availableText] como
/// texto que se muestra en el chip si aceptado, [notAvailableText] como texto de chip
/// en rechazo. [chipFunction] como función que debe retornar `true` o `false` para
/// determinar el valor del chip, y que se ejecuta en cada cambio.
///
/// Ejemplo de implementacion:
/// ```dart
///   () async {
///     final chosenName = await showDialog(RenameDialog());
///     if (isAvailable(chosenName)){
///       // Gestionar resultado
///     }
///   }
/// ```
///
/// Retorna `false` si se cancela. Retorna cualquier [String] si se ha metido un valor válido.
class RenameDialog extends StatefulWidget {
  const RenameDialog({
    super.key,
    this.title = "Renombrar",
    this.content = "Elige un nuevo nombre para tu elemento: ",
    this.rename = "Renombrar",
    this.cancel = "Cancelar",
    this.availableText = "Nombre Disponible",
    this.notAvailableText = "Nombre no Disponible",
    required this.chipFunction,
  });

  final String title;
  final String content;
  final String rename;
  final String cancel;
  final String availableText;
  final String notAvailableText;
  final bool Function(String) chipFunction;

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  //STATE Comenzar con false por defecto
  bool available = false;

  //FORM Input controller
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(widget.title),
          content: Scroll(
            spacing: 5,
            children: [
              Text(widget.content).p(),
              Input(
                controller: textController,
                dialog: true,
                onChange: (newValue) {
                  final result = widget.chipFunction(newValue);
                  setState(() {
                    available = result;
                  });
                },
              ),
              AvailabilityIndicator(
                available: available,
                availableText: widget.availableText,
                unavailableText: widget.notAvailableText,
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, false);
              },
              label: Text(widget.cancel),
              icon: Icon(Icons.close),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (available == false) return;
                Navigator.pop(context, textController.text);
              },
              label: Text(widget.rename),
              icon: Icon(Icons.edit),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPalette.primary,
                foregroundColor: _colorPalette.onPrimary,
              ),
            ),
          ],
        ).constrained(context);
      },
    );
  }
}

//==============
//============== Shadowed
//==============

/// Builds a shadowed simple button.
///
/// - [text] as the text to show
/// - [onPressed] as required action
/// - [buttonColor] as button color
/// - [icon] an optional icon
/// - [expanded] if button should be expanded. Defaults to `false`.
class ShadowedButton extends StatefulWidget {
  const ShadowedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttonColor,
    this.icon,
    this.expanded = false,
  });

  final String text;
  final Function onPressed;
  final Color buttonColor;
  final IconData? icon;
  final bool? expanded;

  @override
  State<ShadowedButton> createState() => _ShadowedButtonState();
}

class _ShadowedButtonState extends State<ShadowedButton> {
  //STATE Determines if the button is currently being hovered
  bool hovered = false;

  // Base color
  late Color baseColor;

  // Shadow Color
  late Color darkerColor;

  @override
  void initState() {
    super.initState();
    final givenColor = HSLColor.fromColor(widget.buttonColor);
    baseColor = givenColor
        .withLightness(
          (givenColor.lightness - guessLightnessValue(givenColor, 0.15)).clamp(
            0,
            1,
          ),
        )
        .toColor();
    final hslBaseColor = HSLColor.fromColor(baseColor);
    darkerColor = hslBaseColor
        .withLightness((hslBaseColor.lightness - 0.1).clamp(0, 1))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    //ATOMS Button
    final button = MouseRegion(
      cursor: hovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onHover: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onPressed(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: darkerColor),

            color: hovered ? darkerColor : baseColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: !hovered
                ? [BoxShadow(offset: Offset(0, 5), color: darkerColor)]
                : [],
          ),
          child: Row(
            spacing: widget.text.isNotEmpty ? 5 : 0,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon ?? Icons.check, color: Colors.white, size: 20),
              Text(widget.text).p(bold: true, color: Colors.white),
            ],
          ),
        ),
      ),
    );

    return widget.expanded!
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Renders a Shadowed Input box.
///
/// - [controller] as the input controller
/// - [color] as the input border color
/// - [onChanged] as something to trigger when changed
/// - [available]? as a possible available value.
/// When `true` or `false` will show an indicator.
/// - [indicatorMessages]? possible indicator messages.
/// Defaults to "Name available / unavailable".
/// Must follow this format:
/// ```
/// {
///   'available': 'Text to show',
///   'unavailable': 'Text to show'
/// }
/// ```
class ShadowedInput extends StatefulWidget {
  const ShadowedInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.available,
    this.indicatorMessages,
    this.centered = false,
    this.scaler = 1,
    this.color,
  });

  final TextEditingController controller;
  final Color? color;
  final Function(String) onChanged;
  final bool? available;
  final Map<String, String>? indicatorMessages;
  final bool centered;
  final double scaler;

  @override
  State<ShadowedInput> createState() => _ShadowedInputState();
}

class _ShadowedInputState extends State<ShadowedInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 3,
              color: widget.color == null
                  ? Colors.blueGrey[800]!
                  : widget.color!,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 3),
                color: widget.color == null
                    ? Colors.blueGrey[800]!
                    : widget.color!,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),

          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(widget.scaler.toDouble())),
            child: TextField(
              textAlign: widget.centered ? TextAlign.center : TextAlign.start,
              onChanged: widget.onChanged,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                focusColor: Colors.blue,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
              controller: widget.controller,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (widget.available != null)
          ShadowedAvailabilityChip(
            available: widget.available!,
            availableNames: widget.indicatorMessages,
          ),
      ],
    );
  }
}

/// Renders a shadowed availability chip
///
/// - [available] if the item is available
/// - [availableNames]? names to show if available / unavailable. Must have following format:
/// ```
/// {
///   'available' : 'Text here' ,
///   'unavailable': 'Other text here'
/// }
/// ```
class ShadowedAvailabilityChip extends StatelessWidget {
  const ShadowedAvailabilityChip({
    super.key,
    required this.available,
    this.availableNames,
  });

  final bool available;
  final Map<String, String>? availableNames;

  @override
  Widget build(BuildContext context) {
    // Base color
    final Color baseColor = available ? Colors.green[700]! : Colors.red[700]!;

    //Darker color
    final darkerColor = HSLColor.fromColor(baseColor)
        .withLightness(
          (HSLColor.fromColor(baseColor).lightness - 0.125).clamp(0, 1),
        )
        .toColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 3, color: darkerColor),
        boxShadow: [BoxShadow(color: darkerColor, offset: Offset(0, 3))],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          Icon(available ? Icons.check : Icons.close, color: Colors.white),
          Text(
            available
                ? (availableNames?['available'] ?? 'Name available')
                : (availableNames?['unavailable'] ?? 'Name unavailable'),
          ).p(color: Colors.white, bold: true),
        ],
      ),
    );
  }
}

/// Renders a list button to select items
///
/// - [text] as the text to show
/// - [onSelected] as code to trigger when selected
class ShadowedSelectableListTile extends StatefulWidget {
  const ShadowedSelectableListTile({
    super.key,
    required this.text,
    required this.onSelected,
    this.initiallySelected = false,
  });

  final String text;
  final Function(bool) onSelected;
  final bool initiallySelected;

  @override
  State<ShadowedSelectableListTile> createState() =>
      _ShadowedSelectableListTileState();
}

class _ShadowedSelectableListTileState
    extends State<ShadowedSelectableListTile> {
  //STATE Currently selected
  late bool selected;

  //STATE Currently Hovered
  bool hovered = false;

  // Color assets
  late Color baseColor;
  late Color darkColor;

  @override
  void initState() {
    selected = widget.initiallySelected;
    final selectionColors = getLuminanceColorVariants(Colors.blueGrey);
    baseColor = selectionColors[0];
    darkColor = selectionColors[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        children: [
          MouseRegion(
            onHover: (_) => setState(() => hovered = true),
            onExit: (_) => setState(() => hovered = false),
            cursor: hovered
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: () {
                setState(() => selected = !selected);
                widget.onSelected(selected);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected ? baseColor : Colors.grey[300],
                  border: Border.all(width: 3, color: darkColor),
                  boxShadow: [
                    BoxShadow(color: darkColor, offset: Offset(0, 3)),
                  ],
                ),
                child: SizedBox.square(
                  dimension: 35,
                  child: selected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 25,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ),
          Text(widget.text).p(),
        ],
      ),
    );
  }
}

/// Builds a shadowed navigation appbar button to switch between pages
///
/// - [text] as the text to show
/// - [onPressed] as required action
/// - [buttonColor] as button color
/// - [selected] if the button is selected
class ShadowedNavigationAppbarButton extends StatefulWidget {
  const ShadowedNavigationAppbarButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttonColor,
    required this.selected,
  });

  final String text;
  final Function onPressed;
  final Color buttonColor;

  final bool selected;

  @override
  State<ShadowedNavigationAppbarButton> createState() =>
      _ShadowedNavigationAppbarButtonState();
}

class _ShadowedNavigationAppbarButtonState
    extends State<ShadowedNavigationAppbarButton> {
  // Base color & darker color versions
  late Color baseColor;
  late Color darkerColor;

  @override
  void initState() {
    final colors = getLuminanceColorVariants(widget.buttonColor);
    baseColor = colors.first;
    darkerColor = colors.last;
    super.initState();
  }

  //STATE Determines if the button is currently being hovered
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: hovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onHover: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onPressed(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: !widget.selected
                ? Border.all(width: 3, color: darkerColor)
                : null,
            color: hovered || widget.selected ? darkerColor : baseColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: !hovered && !widget.selected
                ? [BoxShadow(offset: Offset(0, 5), color: darkerColor)]
                : [],
          ),
          child: Text(widget.text).h5(bold: true, color: Colors.white),
        ),
      ),
    );
  }
}

/// Renders a shadowed style floating action button
///
/// - [text] as the text to show
/// - [color] as the button color
/// - [onPressed] what to do when pressed
/// - [icon] as the icon to show. Defaults to [Icons.check_rounded]
class ShadowedLargeFAB extends StatefulWidget {
  const ShadowedLargeFAB({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.icon = Icons.check_rounded,
    this.animate = true,
  });

  final String text;
  final Color color;
  final Function onPressed;
  final IconData? icon;
  final bool? animate;

  @override
  State<ShadowedLargeFAB> createState() => _ShadowedLargeFABState();
}

class _ShadowedLargeFABState extends State<ShadowedLargeFAB> {
  //STATE Determines if button is being hovered
  bool hovered = false;

  //Working colors
  late Color baseColor;
  late Color darkerColor;

  @override
  void initState() {
    final colorVariants = getLuminanceColorVariants(widget.color);
    baseColor = colorVariants.first;
    darkerColor = colorVariants.last;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: hovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onHover: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onPressed(),
        child: AnimatedContainer(
          padding: EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 15),
          duration: widget.animate!
              ? Duration(milliseconds: 150)
              : Duration.zero,
          decoration: BoxDecoration(
            color: hovered ? darkerColor : baseColor,
            border: Border.all(color: darkerColor, width: 3),
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovered
                ? []
                : [BoxShadow(color: darkerColor, offset: Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Icon(widget.icon, size: 30, color: Colors.white),
              Text(widget.text).h6(color: Colors.white, bold: true),
            ],
          ),
        ),
      ),
    );
  }
}
