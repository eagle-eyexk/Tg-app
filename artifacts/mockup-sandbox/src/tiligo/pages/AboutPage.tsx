import { Clock, Heart, MapPin, ShieldCheck, Zap } from "lucide-react";

const features = [
  {
    icon: Zap,
    title: "Dërgesa e shpejtë",
    text: "Porositë mbërhijnë te dera jote në kohë rekord.",
  },
  {
    icon: ShieldCheck,
    title: "Pagesa e sigurt",
    text: "Të gjitha transaksionet janë të mbrojtura dhe të koduara.",
  },
  {
    icon: Heart,
    title: "Me dashuri",
    text: "Kujdesemi për çdo porosi si të ishte për familjen tonë.",
  },
  {
    icon: MapPin,
    title: "Kudo në Kosovë",
    text: "Mbulojmë qytetet kryesore dhe zonat përreth.",
  },
];

const steps = [
  { n: 1, title: "Zgjidh dyqanin", text: "Shfleto restorante e dyqane afër teje." },
  { n: 2, title: "Bëj porosinë", text: "Shto produktet në shportë dhe paguaj." },
  { n: 3, title: "Ndiqe në kohë reale", text: "Shiko korrierin duke ardhur te ti." },
];

export function AboutPage() {
  return (
    <div className="px-4 pt-5">
      <div className="tg-gradient overflow-hidden rounded-3xl p-6 text-[hsl(var(--brand-dark))]">
        <div className="flex items-center gap-3">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-white/90 p-2">
            <img
              src="/images/tiligo-logo.png"
              alt="TiliGo"
              className="h-full w-full object-contain"
            />
          </div>
          <div>
            <h1 className="text-xl font-extrabold">Rreth TiliGo</h1>
            <p className="text-sm font-medium opacity-80">
              Shpejt, me Dashuri 🇽🇰
            </p>
          </div>
        </div>
        <p className="mt-4 text-sm leading-relaxed opacity-90">
          TiliGo është platforma e dërgesave më e shpejtë në Kosovë. Lidhim
          klientët me restorantet, farmacitë dhe supermarketet e tyre të
          preferuara.
        </p>
      </div>

      <section className="mt-6">
        <h2 className="text-lg font-bold">Pse TiliGo?</h2>
        <div className="mt-3 grid grid-cols-2 gap-3">
          {features.map((f) => {
            const Icon = f.icon;
            return (
              <div
                key={f.title}
                className="rounded-2xl border border-border bg-card p-4"
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="mt-2 text-sm font-bold text-card-foreground">
                  {f.title}
                </h3>
                <p className="mt-1 text-xs text-muted-foreground">{f.text}</p>
              </div>
            );
          })}
        </div>
      </section>

      <section className="mt-6">
        <h2 className="text-lg font-bold">Si Funksionon</h2>
        <div className="mt-3 flex flex-col gap-3">
          {steps.map((s) => (
            <div
              key={s.n}
              className="flex items-center gap-3 rounded-2xl border border-border bg-card p-4"
            >
              <span className="tg-gradient flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-sm font-bold text-[hsl(var(--brand-dark))]">
                {s.n}
              </span>
              <div>
                <h3 className="text-sm font-bold text-card-foreground">
                  {s.title}
                </h3>
                <p className="text-xs text-muted-foreground">{s.text}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      <div className="mt-6 flex items-center justify-center gap-2 text-xs text-muted-foreground">
        <Clock className="h-4 w-4" />
        Mbështetje 24/7 · Impressum
      </div>
    </div>
  );
}
