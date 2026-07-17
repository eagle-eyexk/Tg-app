import { Bell, ChevronRight, MapPin, X } from "lucide-react";

export function PermissionModal({
  onAllow,
  onDismiss,
}: {
  onAllow: () => void;
  onDismiss: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onDismiss}
        aria-hidden="true"
      />

      <div className="relative mx-auto w-full max-w-md rounded-t-3xl bg-[hsl(var(--brand-dark))] px-5 pb-8 pt-6 text-white shadow-2xl">
        <button
          onClick={onDismiss}
          aria-label="Mbyll"
          className="absolute right-4 top-4 flex h-8 w-8 items-center justify-center rounded-full bg-white/10 text-white/80 hover:bg-white/20"
        >
          <X className="h-4 w-4" />
        </button>

        <div className="flex flex-col items-center text-center">
          <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-white p-2">
            <img
              src="/images/tiligo-logo.png"
              alt="TiliGo"
              className="h-full w-full object-contain"
            />
          </div>
          <h2 className="text-xl font-bold">TiliGo ka nevojë</h2>
          <p className="mt-1 text-sm text-white/60">
            për të të ofruar përvojën më të mirë
          </p>
        </div>

        <div className="mt-6 flex flex-col gap-3">
          <PermissionRow
            icon={<Bell className="h-5 w-5" />}
            title="Njoftime për Porosi"
            subtitle="Njoftohu kur porosia jote është gati"
            tint="bg-orange-500/15 text-orange-400"
          />
          <PermissionRow
            icon={<MapPin className="h-5 w-5" />}
            title="Vendndodhja"
            subtitle="Për dërgesa të shpejta te dera jote"
            tint="bg-sky-500/15 text-sky-400"
          />
        </div>

        <button
          onClick={onAllow}
          className="tg-gradient mt-6 w-full rounded-2xl py-4 text-base font-bold text-[hsl(var(--brand-dark))] transition-transform active:scale-[0.98]"
        >
          Lejo Aksesin
        </button>
        <button
          onClick={onDismiss}
          className="mt-2 w-full py-2 text-sm text-white/50 hover:text-white/80"
        >
          Jo tani
        </button>
      </div>
    </div>
  );
}

function PermissionRow({
  icon,
  title,
  subtitle,
  tint,
}: {
  icon: React.ReactNode;
  title: string;
  subtitle: string;
  tint: string;
}) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-white/5 p-3">
      <div
        className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-xl ${tint}`}
      >
        {icon}
      </div>
      <div className="flex-1">
        <p className="text-sm font-semibold">{title}</p>
        <p className="text-xs text-white/50">{subtitle}</p>
      </div>
      <ChevronRight className="h-5 w-5 text-white/30" />
    </div>
  );
}
