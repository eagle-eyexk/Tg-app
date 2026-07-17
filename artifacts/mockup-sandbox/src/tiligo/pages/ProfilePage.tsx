import {
  Bell,
  ChevronRight,
  CreditCard,
  Gift,
  Heart,
  HelpCircle,
  LogIn,
  MapPin,
  Settings,
} from "lucide-react";

const menu = [
  { icon: MapPin, label: "Adresat e mia" },
  { icon: CreditCard, label: "Metodat e pagesës" },
  { icon: Heart, label: "Të preferuarat" },
  { icon: Gift, label: "Kuponë & Oferta" },
  { icon: Bell, label: "Njoftimet" },
  { icon: Settings, label: "Cilësimet" },
  { icon: HelpCircle, label: "Ndihmë & Mbështetje" },
];

export function ProfilePage() {
  return (
    <div className="px-4 pt-5">
      <h1 className="text-xl font-bold">Profili</h1>

      <div className="mt-4 flex items-center gap-4 rounded-3xl border border-border bg-card p-5">
        <div className="tg-gradient flex h-16 w-16 items-center justify-center rounded-full text-2xl font-bold text-[hsl(var(--brand-dark))]">
          M
        </div>
        <div className="flex-1">
          <h2 className="text-base font-bold text-card-foreground">Mysafir</h2>
          <p className="text-sm text-muted-foreground">
            Regjistrohu për të ruajtur porositë
          </p>
        </div>
      </div>

      <button className="tg-gradient mt-4 flex w-full items-center justify-center gap-2 rounded-2xl py-3.5 text-sm font-bold text-[hsl(var(--brand-dark))]">
        <LogIn className="h-4 w-4" />
        Hyr ose Regjistrohu falas
      </button>

      <div className="mt-5 overflow-hidden rounded-3xl border border-border bg-card">
        {menu.map((item, index) => {
          const Icon = item.icon;
          return (
            <button
              key={item.label}
              className={`flex w-full items-center gap-3 px-4 py-3.5 text-left transition-colors hover:bg-secondary ${
                index !== menu.length - 1 ? "border-b border-border" : ""
              }`}
            >
              <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-secondary text-foreground">
                <Icon className="h-4 w-4" />
              </span>
              <span className="flex-1 text-sm font-medium text-card-foreground">
                {item.label}
              </span>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </button>
          );
        })}
      </div>

      <p className="mt-6 text-center text-xs text-muted-foreground">
        TiliGo v2.0 · Shpejt, me Dashuri
      </p>
    </div>
  );
}
