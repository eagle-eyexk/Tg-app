import { Minus, Plus, ShoppingCart } from "lucide-react";

import type { CartLine } from "../TiliGoApp";
import { formatEur } from "../data";

const DELIVERY_FEE = 1.0;

export function CartPage({
  cart,
  onUpdateQty,
  onBrowse,
}: {
  cart: CartLine[];
  onUpdateQty: (index: number, delta: number) => void;
  onBrowse: () => void;
}) {
  const subtotal = cart.reduce((sum, l) => sum + l.price * l.qty, 0);
  const total = cart.length > 0 ? subtotal + DELIVERY_FEE : 0;

  if (cart.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center px-6 pt-24 text-center">
        <div className="flex h-20 w-20 items-center justify-center rounded-full bg-secondary">
          <ShoppingCart className="h-9 w-9 text-muted-foreground" />
        </div>
        <h1 className="mt-4 text-xl font-bold">Shporta është bosh</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Shto produkte nga dyqanet e hapura për të filluar porosinë.
        </p>
        <button
          onClick={onBrowse}
          className="tg-gradient mt-6 rounded-2xl px-6 py-3 text-sm font-bold text-[hsl(var(--brand-dark))]"
        >
          Shfleto dyqanet
        </button>
      </div>
    );
  }

  return (
    <div className="px-4 pt-5">
      <h1 className="text-xl font-bold">Shporta</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        {cart.length} artikuj në shportë
      </p>

      <div className="mt-5 flex flex-col gap-3">
        {cart.map((line, index) => (
          <div
            key={`${line.storeId}-${index}`}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3"
          >
            <div className="flex-1">
              <p className="text-sm font-semibold text-card-foreground">
                {line.name}
              </p>
              <p className="text-xs text-muted-foreground">{line.storeName}</p>
              <p className="mt-1 text-sm font-bold text-primary">
                {formatEur(line.price)}
              </p>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => onUpdateQty(index, -1)}
                aria-label="Ul sasinë"
                className="flex h-8 w-8 items-center justify-center rounded-full bg-secondary text-secondary-foreground"
              >
                <Minus className="h-4 w-4" />
              </button>
              <span className="w-5 text-center text-sm font-bold">
                {line.qty}
              </span>
              <button
                onClick={() => onUpdateQty(index, 1)}
                aria-label="Rrit sasinë"
                className="tg-gradient flex h-8 w-8 items-center justify-center rounded-full text-[hsl(var(--brand-dark))]"
              >
                <Plus className="h-4 w-4" />
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-5 rounded-2xl border border-border bg-card p-4">
        <div className="flex justify-between py-1 text-sm text-muted-foreground">
          <span>Nëntotali</span>
          <span>{formatEur(subtotal)}</span>
        </div>
        <div className="flex justify-between py-1 text-sm text-muted-foreground">
          <span>Dërgesa</span>
          <span>{formatEur(DELIVERY_FEE)}</span>
        </div>
        <div className="mt-1 flex justify-between border-t border-border pt-2 text-base font-bold">
          <span>Totali</span>
          <span>{formatEur(total)}</span>
        </div>
      </div>

      <button className="tg-gradient mt-4 w-full rounded-2xl py-4 text-base font-bold text-[hsl(var(--brand-dark))] transition-transform active:scale-[0.98]">
        Vazhdo te pagesa · {formatEur(total)}
      </button>
    </div>
  );
}
