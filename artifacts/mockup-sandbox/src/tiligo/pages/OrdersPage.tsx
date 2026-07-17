import { CheckCircle2, ChefHat, Bike } from "lucide-react";

import { formatEur, orders, type OrderStatus } from "../data";

const statusMeta: Record<
  OrderStatus,
  { label: string; icon: typeof Bike; className: string }
> = {
  duke_u_pergatitur: {
    label: "Duke u përgatitur",
    icon: ChefHat,
    className: "bg-orange-100 text-orange-700",
  },
  rruges: {
    label: "Në rrugë",
    icon: Bike,
    className: "bg-sky-100 text-sky-700",
  },
  dorezuar: {
    label: "Dorëzuar",
    icon: CheckCircle2,
    className: "bg-green-100 text-green-700",
  },
};

export function OrdersPage() {
  return (
    <div className="px-4 pt-5">
      <h1 className="text-xl font-bold">Porositë e Mia</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Ndiq porositë e tua në kohë reale
      </p>

      <div className="mt-5 flex flex-col gap-4">
        {orders.map((order) => {
          const meta = statusMeta[order.status];
          const Icon = meta.icon;
          return (
            <article
              key={order.id}
              className="rounded-3xl border border-border bg-card p-4 shadow-sm"
            >
              <div className="flex items-center gap-3">
                <img
                  src={order.storeImage || "/placeholder.svg"}
                  alt={order.storeName}
                  className="h-14 w-14 rounded-2xl object-cover"
                />
                <div className="flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <h3 className="font-bold text-card-foreground">
                      {order.storeName}
                    </h3>
                    <span className="text-xs text-muted-foreground">
                      #{order.id}
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground">{order.date}</p>
                  <span
                    className={`mt-1.5 inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold ${meta.className}`}
                  >
                    <Icon className="h-3.5 w-3.5" />
                    {meta.label}
                    {order.status === "rruges" && order.etaMinutes
                      ? ` · ${order.etaMinutes} min`
                      : ""}
                  </span>
                </div>
              </div>

              <div className="mt-3 border-t border-border pt-3">
                {order.items.map((item) => (
                  <div
                    key={item.name}
                    className="flex items-center justify-between py-0.5 text-sm"
                  >
                    <span className="text-muted-foreground">
                      {item.qty}× {item.name}
                    </span>
                    <span className="text-card-foreground">
                      {formatEur(item.price * item.qty)}
                    </span>
                  </div>
                ))}
                <div className="mt-2 flex items-center justify-between border-t border-border pt-2 text-sm font-bold">
                  <span>Totali</span>
                  <span>{formatEur(order.total)}</span>
                </div>
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}
