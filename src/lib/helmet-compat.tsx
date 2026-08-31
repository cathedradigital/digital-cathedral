/**
 * Compatibility shim for react-helmet-async: applies <title>, <meta>,
 * <link> and <script> children to document.head on mount/update and
 * removes them on unmount. No-op during SSR.
 */
import * as React from "react";

const MARKER = "data-helmet-compat";

export function HelmetProvider({ children }: { children?: React.ReactNode }) {
  return <>{children}</>;
}

function applyTag(el: HTMLElement, attrs: Record<string, unknown>): void {
  for (const [key, value] of Object.entries(attrs)) {
    if (value == null || value === false) continue;
    if (key === "children" || key === "key" || key === "ref") continue;
    const attr = key === "className" ? "class" : key;
    el.setAttribute(attr, String(value));
  }
  el.setAttribute(MARKER, "true");
}

export function Helmet({ children }: { children?: React.ReactNode }): null {
  React.useEffect(() => {
    if (typeof document === "undefined") return;
    const added: HTMLElement[] = [];
    let previousTitle: string | null = null;

    React.Children.forEach(children, (child) => {
      if (!React.isValidElement(child)) return;
      const type = child.type as string;
      const props = child.props as Record<string, unknown>;
      if (typeof type !== "string") return;

      if (type === "title") {
        previousTitle = document.title;
        const text = React.Children.toArray(props.children as React.ReactNode).join("");
        document.title = text;
        return;
      }
      if (type === "meta" || type === "link" || type === "script" || type === "style" || type === "base") {
        const el = document.createElement(type);
        applyTag(el, props);
        if (type === "script" && typeof props.children === "string") {
          el.textContent = props.children;
        }
        document.head.appendChild(el);
        added.push(el);
      }
    });

    return () => {
      added.forEach((el) => el.parentNode?.removeChild(el));
      if (previousTitle != null) document.title = previousTitle;
    };
  });

  return null;
}

export default Helmet;
