import { Home, Info, ShoppingCart, User, ClipboardList } from "lucide-react";

import { cn } from "@/lib/utils";

export type PageId = "home" | "orders" | "cart" | "about" | "profile";

const items: { id: PageId; label: string; icon: typeof Home }[] = [
  { id: "home", label: "Kryefaqja", icon: Home },
  { id: "orders", label: "Porositë", icon: ClipboardList },
  { id: "cart", label: "Shporta", icon: ShoppingCart },
  { id: "about", label: "Rreth", icon: Info },
  { id: "profile", label: "Profili", icon: User },
];

export function BottomNav({
  active,
  onChange,
  cartCount,
}: {
  active: PageId;
  onChange: (id: PageId) => void;
  cartCount: number;
}) {
  return (
    <nav className="tg-safe-bottom fixed inset-x-0 bottom-0 z-30 mx-auto flex w-full max-w-md items-stretch justify-around border-t border-border bg-background/80 px-2 py-2 backdrop-blur-xl">
      {items.map((item) => {
        const isActive = active === item.id;
        const Icon = item.icon;
        return (
          <button
            key={item.id}
            onClick={() => onChange(item.id)}
            className={cn(
              "relative flex min-h-[44px] flex-1 flex-col items-center justify-center gap-1 rounded-xl py-1 text-xs font-medium transition-colors",
              isActive ? "text-primary" : "text-muted-foreground",
            )}
            aria-current={isActive ? "page" : undefined}
          >
            <span className="relative">
              <Icon
                className="h-5 w-5"
                strokeWidth={isActive ? 2.5 : 2}
                aria-hidden="true"
              />
              {item.id === "cart" && cartCount > 0 && (
                <span className="tg-gradient absolute -right-2 -top-1.5 flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[10px] font-bold text-[hsl(var(--brand-dark))]">
                  {cartCount}
                </span>
              )}
            </span>
            {item.label}
          </button>
        );
      })}
    </nav>
  );
}
