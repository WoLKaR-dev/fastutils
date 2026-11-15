import 'package:fastutils/fastutils.dart';
import 'package:flutter/material.dart';

ColorScheme _colorPalette = FastUtils().colorPalette;

/// Can be implemented to render a minimalist rounded button.
///
/// - [bold] as a boolean to decide if the text should be bold.
/// - [text]  as the text to show.
/// - [onTap] what will happen when pressed.
/// - [icon] an optional icon that will be animated to show next page.
/// - [padding] an optional padding to set to the button.
/// - [iconPosition] an optional icon position to set to the button.
/// - [roundedPixels] an optional rounded pixels to set to the button.
/// - [trailing] an optional trailing widget to set to the button.
/// - [onLongPress] an optional onLongPress
abstract class RoundedButton extends StatelessWidget {
  final bool bold;
  final String text;
  final Function(BuildContext) onTap;
  final IconData? icon;
  final EdgeInsets? padding;
  final RoundedButtonIconPosition? iconPosition;
  final double? roundedPixels;
  final Widget? trailing;
  final Function(BuildContext)? onLongPress;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.onLongPress,
    this.bold = true,
    this.icon = Icons.arrow_forward_ios_rounded,
    this.padding = const EdgeInsets.all(15),
    this.iconPosition = RoundedButtonIconPosition.right,
    this.roundedPixels = 360,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    //PART Button width
    final double width = switch (FastUtils().screenSize) {
      ScreenSize.small => MediaQuery.sizeOf(context).width * 0.95,
      ScreenSize.regular => MediaQuery.sizeOf(context).width * 0.95,
      ScreenSize.large => MediaQuery.sizeOf(context).width * 0.60,
      ScreenSize.xlarge => MediaQuery.sizeOf(context).width * 0.30,
      ScreenSize.xxlarge => MediaQuery.sizeOf(context).width * 0.30,
    };

    //ATOMS Text design
    final textDesign = Text(
      text,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        fontSize: switch (FastUtils().screenSize) {
          ScreenSize.small => 25,
          ScreenSize.regular => 25,
          ScreenSize.large => 30,
          ScreenSize.xlarge => 30,
          ScreenSize.xxlarge => 30,
        },
      ),
    );

    //ATOMS Icon design
    final buttonTrailing =
        trailing ??
        Icon(
          icon,
          size: switch (FastUtils().screenSize) {
            ScreenSize.small => 25,
            ScreenSize.regular => 27,
            ScreenSize.large => 30,
            ScreenSize.xlarge => 35,
            ScreenSize.xxlarge => 35,
          },
        );

    //ATOMS Main design
    final mainDesign = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: _colorPalette.surfaceContainer,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(roundedPixels!),
      ),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (iconPosition == RoundedButtonIconPosition.left) buttonTrailing,
          Expanded(child: textDesign),
          if (iconPosition == RoundedButtonIconPosition.right) buttonTrailing,
        ],
      ),
    );

    //LAYOUT Main layout
    final mainLayout = GestureDetector(
      onLongPress: onLongPress == null
          ? null
          : () {
              onLongPress!(context);
            },
      onTap: () {
        onTap(context);
      },
      child: mainDesign,
    );

    return mainLayout;
  }
}

/// Can be implemented to render a minimalist square button.
///
/// - [useBorder]  if the border should be rendered or not.
/// - [extraInfo]  as the extra information to show.
/// - [text]       as the text to show.
/// - [color]      as the color to render.
/// - [upperIcon]  as the icon to show.
/// - [onLongTap]  what will happen when holding.
/// - [onPressed]  what will happen when pressed.
abstract class SquaredButton extends StatelessWidget {
  final bool? useBorder;
  final Widget? extraInfo;
  final String text;
  final Color? color;
  final IconData? upperIcon;
  final Function(BuildContext)? onLongTap;
  final Function(BuildContext) onPressed;

  SquaredButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.upperIcon = Icons.arrow_outward,
    this.extraInfo,
    this.useBorder = true,
    this.onLongTap,
    Color? color,
  }) : color = color ?? _colorPalette.surfaceContainer;

  @override
  Widget build(BuildContext context) {
    final topColor = color!.computeLuminance() > 0.15
        ? Colors.black
        : _colorPalette.onSurface;

    return GestureDetector(
      onLongPress: () {
        onLongTap?.call(context);
      },
      onTap: () {
        onPressed.call(context);
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: useBorder! ? Border.all(color: Colors.black) : null,
          borderRadius: BorderRadius.circular(15),
          color: color != _colorPalette.surfaceContainer
              ? color!.toPastel()
              : _colorPalette.surfaceContainer,
        ),
        width: switch (FastUtils().screenSize) {
          ScreenSize.small => 170,
          ScreenSize.regular => 200,
          ScreenSize.large => 225,
          ScreenSize.xlarge => 255,
          ScreenSize.xxlarge => 255,
        },
        child: AspectRatio(
          aspectRatio: 1 / 1.15,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(360),
                ),
                padding: EdgeInsets.all(5),
                child: Icon(upperIcon, color: topColor),
              ),
              Column(
                spacing: 15,

                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //SECTION Button Text
                  if ([
                    ScreenSize.small,
                    ScreenSize.regular,
                  ].contains(FastUtils().screenSize))
                    Text(text).h6(color: topColor)
                  else
                    Text(text).h4(color: topColor),

                  //SECTION Extra info section. Here you can add your stats widget.
                  extraInfo ?? SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Can be implemented to render a shadowed large button.
///
/// - [text] as the text to show.
/// - [baseColor] as the color to render.
/// **Important**: This color will be modified for accesibility.
/// - [nextIcon] an icon that will be animated to show next page.
/// - [onTap] what will happen when pressed.
/// - [decorationIcon] an optional button to show near the text.
abstract class ShadowedLargeButton extends StatefulWidget {
  const ShadowedLargeButton({
    super.key,
    required this.text,
    required this.baseColor,
    required this.onTap,
    this.nextIcon,
    this.decorationIcon,
    this.animate = true,
    this.chipColor,
  });

  final String text;
  final Color baseColor;
  final IconData? nextIcon;
  final Function(BuildContext) onTap;
  final IconData? decorationIcon;
  final bool? animate;
  final Color? chipColor;

  @override
  State<ShadowedLargeButton> createState() => _ShadowedLargeButtonState();
}

class _ShadowedLargeButtonState extends State<ShadowedLargeButton> {
  //STATE Determines if button is hovered
  bool hovered = false;

  // Base color
  late Color baseColor;

  // Shadow Color
  late Color darkerColor;

  @override
  void initState() {
    super.initState();
    // Transform base color to hsl
    HSLColor baseHSLColor = HSLColor.fromColor(widget.baseColor);

    // Obtain real base color
    baseColor = baseHSLColor
        .withLightness(
          (baseHSLColor.lightness - guessLightnessValue(baseHSLColor, 0.15))
              .clamp(0, 1),
        )
        .toColor();

    // set new shadow color
    baseHSLColor = HSLColor.fromColor(baseColor);
    darkerColor = baseHSLColor
        .withLightness((baseHSLColor.lightness - 0.1).clamp(0, 1))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: hovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onHover: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(context),
        child: AnimatedContainer(
          padding: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
            right: !hovered ? 25 : 10,
          ),
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
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.chipColor != null)
                      Container(
                        width: 10,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: widget.chipColor,
                          borderRadius: BorderRadius.circular(360),
                        ),
                      ),

                    if (widget.decorationIcon != null)
                      Icon(
                        widget.decorationIcon,
                        color: Colors.white,
                        size: 35,
                      ),

                    Text(widget.text).h5(bold: true, color: Colors.white),
                  ],
                ),
              ),
              if (widget.nextIcon != null)
                Icon(widget.nextIcon, size: 35, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
