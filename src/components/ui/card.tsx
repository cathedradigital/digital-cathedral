import * as React from "react";
import { cn } from "@/lib/utils";
import { motion, HTMLMotionProps } from "framer-motion";
import { useReadingSettings } from "@/contexts/ReadingSettingsContext";

/* --- Unified Card Implementation (Card Único) --- */

interface CardProps extends HTMLMotionProps<"div"> {
  variant?: 'default' | 'interactive' | 'outline' | 'glass';
  padding?: 'none' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
  as?: React.ElementType;
}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant = 'default', padding = 'md', as, children, ...props }, ref) => {
    const { settings } = useReadingSettings();

    const paddingMap = {
      none: '',
      sm: 'p-spacing-sm md:p-spacing-lg',
      md: 'p-spacing-md md:p-spacing-xl',
      lg: 'p-spacing-lg md:p-spacing-2xl',
      xl: 'p-spacing-xl md:p-spacing-3xl',
      '2xl': 'p-spacing-2xl md:p-spacing-4xl',
    };

    const variantStyles = {
      default: 'bg-card/40 backdrop-blur-sm border border-primary/[0.03] dark:border-white/[0.006] shadow-premium',
      interactive: 'bg-card/40 backdrop-blur-sm border border-primary/[0.03] dark:border-white/[0.006] shadow-premium hover:shadow-premium-hover hover:border-primary/8 hover:bg-primary/[0.008] active:scale-[0.995] cursor-pointer transition-all duration-300',
      outline: 'bg-transparent border border-primary/[0.06] dark:border-white/[0.012]',
      glass: 'bg-white/[0.015] dark:bg-black/[0.015] backdrop-blur-2xl border border-white/[0.025] dark:border-white/[0.006] shadow-premium-none',
    };

    const cardContent = (
      <div
        className={cn(
          "relative overflow-hidden rounded-premium premium-card",
          variantStyles[variant],
          paddingMap[padding],
          "focus-within:ring-2 focus-within:ring-primary/12 focus-within:ring-offset-1 outline-none",
          className
        )}
        ref={ref}
        {...props}
      >
        {children}
      </div>
    );

    if (as) {
      const MotionWrapper = motion[as as keyof typeof motion] as React.ComponentType<React.HTMLAttributes<HTMLElement>>;
      if (MotionWrapper && settings?.reduceAnimations) {
        return <MotionWrapper className={cn(variantStyles[variant], paddingMap[padding], className)} {...props}>{children}</MotionWrapper>;
      }
      if (MotionWrapper) {
        return (
          <MotionWrapper
            className={cn(variantStyles[variant], paddingMap[padding], "focus-within:ring-2 focus-within:ring-primary/12 focus-within:ring-offset-1 outline-none", className)}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            {...props}
          >
            {children}
          </MotionWrapper>
        );
      }
    }

    if (!settings?.reduceAnimations) {
      return (
        <motion.div
          className={cn(variantStyles[variant], paddingMap[padding], "focus-within:ring-2 focus-within:ring-primary/12 focus-within:ring-offset-1 outline-none", className)}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          ref={ref}
          {...props}
        >
          {children}
        </motion.div>
      );
    }

    return cardContent;
  }
);
Card.displayName = "Card";

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-spacing-sm mb-spacing-md", className)}
    {...props}
  />
));
CardHeader.displayName = "CardHeader";

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      "text-premium-2xl font-display font-light leading-none tracking-premium-tight text-primary",
      className
    )}
    {...props}
  />
));
CardTitle.displayName = "CardTitle";

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn("text-premium-sm text-muted-foreground/60", className)}
    {...props}
  />
));
CardDescription.displayName = "CardDescription";

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("", className)} {...props} />
));
CardContent.displayName = "CardContent";

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center mt-spacing-md pt-spacing-md border-t border-primary/[0.03]", className)}
    {...props}
  />
));
CardFooter.displayName = "CardFooter";

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent };
