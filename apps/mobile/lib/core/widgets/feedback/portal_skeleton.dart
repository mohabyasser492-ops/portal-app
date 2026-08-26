import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_radius.dart';
import '../../../app/theme/portal_spacing.dart';

/// Shapes supported by [PortalSkeleton].
enum PortalSkeletonShape { rectangle, roundedRectangle, circle }

/// A reusable placeholder displayed while content is loading.
///
/// The skeleton preserves the approximate dimensions of the content that will
/// replace it. This reduces layout movement while data is being loaded.
///
/// The component is excluded from accessibility semantics because it is
/// decorative. A meaningful loading message should be provided separately
/// through a component such as PortalLoadingState.
class PortalSkeleton extends StatefulWidget {
  const PortalSkeleton({
    required this.width,
    required this.height,
    this.shape = PortalSkeletonShape.roundedRectangle,
    this.borderRadius,
    this.animate = true,
    super.key,
  }) : assert(width > 0, 'width must be greater than zero.'),
       assert(height > 0, 'height must be greater than zero.'),
       assert(
         shape != PortalSkeletonShape.circle || width == height,
         'A circular skeleton must have equal width and height.',
       );

  /// Width of the placeholder.
  ///
  /// [double.infinity] may be used when the parent provides finite horizontal
  /// constraints.
  final double width;

  /// Height of the placeholder.
  final double height;

  /// Visual shape of the placeholder.
  final PortalSkeletonShape shape;

  /// Optional custom radius for a rounded rectangular placeholder.
  ///
  /// When omitted, [PortalRadius.md] is used.
  final BorderRadiusGeometry? borderRadius;

  /// Whether the placeholder should animate.
  final bool animate;

  @override
  State<PortalSkeleton> createState() => _PortalSkeletonState();
}

class _PortalSkeletonState extends State<PortalSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    if (widget.animate) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PortalSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate == widget.animate) {
      return;
    }

    if (widget.animate) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.animate
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return DecoratedBox(
                    decoration: _buildDecoration(animationValue: _animation.value),
                  );
                },
              )
            : DecoratedBox(decoration: _buildDecoration(animationValue: 0)),
      ),
    );
  }

  BoxDecoration _buildDecoration({required double animationValue}) {
    final color = Color.lerp(
      PortalColors.surfaceTertiary,
      PortalColors.neutral200,
      animationValue,
    )!;

    return BoxDecoration(color: color, shape: _boxShape, borderRadius: _resolvedBorderRadius);
  }

  BoxShape get _boxShape {
    if (widget.shape == PortalSkeletonShape.circle) {
      return BoxShape.circle;
    }

    return BoxShape.rectangle;
  }

  BorderRadiusGeometry? get _resolvedBorderRadius {
    return switch (widget.shape) {
      PortalSkeletonShape.rectangle => BorderRadius.zero,
      PortalSkeletonShape.roundedRectangle =>
        widget.borderRadius ?? BorderRadius.circular(PortalRadius.md),
      PortalSkeletonShape.circle => null,
    };
  }
}

/// A skeleton representation of a text block.
///
/// Multiple horizontal skeleton lines are displayed to approximate a paragraph.
/// The last line is shorter by default to resemble natural text wrapping.
class PortalTextSkeleton extends StatelessWidget {
  const PortalTextSkeleton({
    required this.width,
    this.lines = 3,
    this.lineHeight = 14,
    this.lineSpacing = PortalSpacing.sm,
    this.lastLineWidthFactor = 0.68,
    this.animate = true,
    super.key,
  }) : assert(width > 0, 'width must be greater than zero.'),
       assert(lines > 0, 'lines must be greater than zero.'),
       assert(lineHeight > 0, 'lineHeight must be greater than zero.'),
       assert(lineSpacing >= 0, 'lineSpacing cannot be negative.'),
       assert(
         lastLineWidthFactor > 0 && lastLineWidthFactor <= 1,
         'lastLineWidthFactor must be greater than zero and less than or '
         'equal to one.',
       );

  /// Maximum width of each text line.
  final double width;

  /// Number of skeleton lines.
  final int lines;

  /// Height of each skeleton line.
  final double lineHeight;

  /// Vertical spacing between lines.
  final double lineSpacing;

  /// Width of the final line relative to [width].
  ///
  /// For example, `0.68` makes the final line 68 percent of the full width.
  final double lastLineWidthFactor;

  /// Whether the skeleton lines should animate.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final currentWidth = isLastLine ? width * lastLineWidthFactor : width;

        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: isLastLine ? 0 : lineSpacing),
          child: PortalSkeleton(
            width: currentWidth,
            height: lineHeight,
            animate: animate,
            shape: PortalSkeletonShape.roundedRectangle,
            borderRadius: BorderRadius.circular(PortalRadius.sm),
          ),
        );
      }),
    );
  }
}

/// A skeleton representation of a list tile or compact information row.
///
/// The component can display:
///
/// - An optional circular leading placeholder
/// - Two text-line placeholders
/// - An optional trailing placeholder
class PortalListTileSkeleton extends StatelessWidget {
  const PortalListTileSkeleton({
    this.width = double.infinity,
    this.showLeading = true,
    this.showTrailing = false,
    this.animate = true,
    super.key,
  }) : assert(width > 0, 'width must be greater than zero.');

  /// Width of the complete placeholder row.
  final double width;

  /// Whether a circular leading placeholder is displayed.
  final bool showLeading;

  /// Whether a trailing placeholder is displayed.
  final bool showTrailing;

  /// Whether the placeholders should animate.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLeading) ...[
            PortalSkeleton(
              width: 48,
              height: 48,
              shape: PortalSkeletonShape.circle,
              animate: animate,
            ),
            const SizedBox(width: PortalSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return PortalSkeleton(
                      width: constraints.maxWidth,
                      height: 16,
                      animate: animate,
                    );
                  },
                ),
                const SizedBox(height: PortalSpacing.sm),
                FractionallySizedBox(
                  widthFactor: 0.64,
                  alignment: AlignmentDirectional.centerStart,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return PortalSkeleton(
                        width: constraints.maxWidth,
                        height: 12,
                        animate: animate,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: PortalSpacing.md),
            PortalSkeleton(width: 24, height: 24, animate: animate),
          ],
        ],
      ),
    );
  }
}
