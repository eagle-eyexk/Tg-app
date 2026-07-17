import { Bike, Clock, Star, Wallet } from "lucide-react";

import { formatEur, type Store } from "../data";

export function StoreCard({
  store,
  onOrder,
}: {
  store: Store;
  onOrder: (store: Store) => void;
}) {
  return (
    <article className="overflow-hidden rounded-3xl border border-border bg-card shadow-sm">
      <div className="relative h-44 w-full">
        <img
          src={store.image || "/placeholder.svg"}
          alt={store.name}
          className="h-full w-full object-cover"
        />
        <span className="absolute left-3 top-3 rounded-lg bg-black/55 px-2.5 py-1 text-xs font-semibold text-white backdrop-blur-sm">
          {store.categoryLabel}
        </span>
        <span
          className={`absolute right-3 top-3 flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-semibold ${
            store.isOpen
              ? "bg-primary text-primary-foreground"
              : "bg-muted text-muted-foreground"
          }`}
        >
          <span
            className={`h-1.5 w-1.5 rounded-full ${
              store.isOpen ? "bg-[hsl(var(--brand-dark))]" : "bg-current"
            }`}
          />
          {store.isOpen ? "Hapur" : "Mbyllur"}
        </span>
      </div>

      <div className="p-4">
        <div className="flex items-center justify-between gap-2">
          <h3 className="text-base font-bold text-card-foreground">
            {store.name}
          </h3>
          <span className="flex items-center gap-1 text-sm font-semibold text-card-foreground">
            <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
            {store.rating.toFixed(1)}
          </span>
        </div>

        <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1.5 text-sm text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <Clock className="h-4 w-4" />
            {store.deliveryMinutes} min
          </span>
          <span className="flex items-center gap-1.5">
            <Bike className="h-4 w-4" />
            Dërgesa {formatEur(store.deliveryFee)}
          </span>
          <span className="flex items-center gap-1.5">
            <Wallet className="h-4 w-4" />
            Min {formatEur(store.minOrder)}
          </span>
        </div>

        <button
          onClick={() => onOrder(store)}
          disabled={!store.isOpen}
          className="tg-gradient mt-4 w-full rounded-2xl py-3 text-sm font-bold text-[hsl(var(--brand-dark))] transition-transform active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-40"
        >
          {store.isOpen ? "Porosit tani" : "Mbyllur tani"}
        </button>
      </div>
    </article>
  );
}
