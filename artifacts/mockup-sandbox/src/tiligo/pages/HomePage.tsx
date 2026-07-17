import { useMemo, useState } from "react";

import { CategoryChips } from "../components/CategoryChips";
import { HeroSection } from "../components/HeroSection";
import { StoreCard } from "../components/StoreCard";
import type { Store } from "../data";

export function HomePage({
  stores,
  onOrder,
}: {
  stores: Store[];
  onOrder: (store: Store) => void;
}) {
  const [category, setCategory] = useState("all");
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    return stores.filter((store) => {
      const matchesCategory =
        category === "all" || store.categoryId === category;
      const matchesQuery =
        query.trim() === "" ||
        store.name.toLowerCase().includes(query.toLowerCase()) ||
        store.categoryLabel.toLowerCase().includes(query.toLowerCase());
      return matchesCategory && matchesQuery;
    });
  }, [stores, category, query]);

  const openCount = filtered.filter((s) => s.isOpen).length;

  return (
    <div>
      <HeroSection query={query} onQueryChange={setQuery} />

      <div className="mt-5">
        <h2 className="px-4 text-lg font-bold">
          Kategoritë <span className="text-muted-foreground">Popullore</span>
        </h2>
        <div className="mt-3">
          <CategoryChips selected={category} onSelect={setCategory} />
        </div>
      </div>

      <div className="mt-6 px-4">
        <div className="flex items-baseline gap-2">
          <h2 className="text-lg font-bold">Dyqane të Hapura</h2>
          <span className="text-sm font-semibold text-primary">
            ({openCount})
          </span>
        </div>

        <div className="mt-4 flex flex-col gap-4">
          {filtered.length === 0 ? (
            <p className="rounded-2xl bg-secondary p-6 text-center text-sm text-muted-foreground">
              Asnjë dyqan nuk u gjet për kërkimin tënd.
            </p>
          ) : (
            filtered.map((store) => (
              <StoreCard key={store.id} store={store} onOrder={onOrder} />
            ))
          )}
        </div>
      </div>
    </div>
  );
}
