import { cn } from "@/lib/utils";

import { categories } from "../data";

export function CategoryChips({
  selected,
  onSelect,
}: {
  selected: string;
  onSelect: (id: string) => void;
}) {
  return (
    <div className="tg-no-scrollbar flex gap-2 overflow-x-auto px-4 py-1">
      {categories.map((cat) => {
        const isActive = selected === cat.id;
        return (
          <button
            key={cat.id}
            onClick={() => onSelect(cat.id)}
            className={cn(
              "flex shrink-0 items-center gap-1.5 rounded-full px-4 py-2 text-sm font-semibold transition-colors",
              isActive
                ? "tg-gradient text-[hsl(var(--brand-dark))]"
                : "bg-secondary text-secondary-foreground hover:bg-secondary/70",
            )}
          >
            <span aria-hidden="true">{cat.emoji}</span>
            {cat.label}
          </button>
        );
      })}
    </div>
  );
}
