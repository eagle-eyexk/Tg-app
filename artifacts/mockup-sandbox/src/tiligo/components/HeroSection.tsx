import { Search } from "lucide-react";

import { quickSearches } from "../data";

export function HeroSection({
  query,
  onQueryChange,
}: {
  query: string;
  onQueryChange: (value: string) => void;
}) {
  return (
    <section className="relative overflow-hidden">
      <img
        src="/images/hero-food.png"
        alt="Ushqime të freskëta për dërgesë"
        className="absolute inset-0 h-full w-full object-cover"
      />
      <div className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/60 to-black/80" />

      <div className="relative flex flex-col items-center px-5 pb-6 pt-8 text-center text-white">
        <div className="mb-3 flex h-16 w-16 items-center justify-center rounded-2xl bg-white/95 p-2">
          <img
            src="/images/tiligo-logo.png"
            alt="TiliGo"
            className="h-full w-full object-contain"
          />
        </div>

        <h1 className="text-2xl font-extrabold leading-tight text-balance">
          TiliGo — <span className="tg-gradient-text">Shpejt</span>, me Dashuri
        </h1>
        <p className="mt-1 text-sm text-white/80">
          {"Dërgesa më e shpejtë në Kosovë 🇽🇰"}
        </p>

        <form
          className="mt-5 flex w-full items-center gap-2"
          onSubmit={(e) => e.preventDefault()}
        >
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={query}
              onChange={(e) => onQueryChange(e.target.value)}
              placeholder="Kërko restorante, produkte..."
              aria-label="Kërko"
              className="h-12 w-full rounded-2xl bg-white pl-10 pr-3 text-base text-foreground outline-none ring-primary/40 focus:ring-2"
            />
          </div>
          <button
            type="submit"
            className="tg-gradient h-12 shrink-0 rounded-2xl px-5 text-sm font-bold text-[hsl(var(--brand-dark))]"
          >
            Kërko
          </button>
        </form>

        <div className="tg-no-scrollbar mt-4 flex w-full gap-2 overflow-x-auto pb-1">
          {quickSearches.map((item) => (
            <button
              key={item.label}
              onClick={() => onQueryChange(item.label)}
              className="shrink-0 rounded-full border border-white/25 bg-white/10 px-3 py-1.5 text-xs font-medium text-white backdrop-blur-sm transition-colors hover:bg-white/20"
            >
              {item.label} {item.emoji}
            </button>
          ))}
        </div>
      </div>
    </section>
  );
}
