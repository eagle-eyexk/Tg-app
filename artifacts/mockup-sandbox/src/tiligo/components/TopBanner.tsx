import { X } from "lucide-react";

export function TopBanner({ onClose }: { onClose: () => void }) {
  return (
    <div className="tg-gradient sticky top-0 z-30 flex items-center gap-2 px-4 py-2 text-sm text-[hsl(var(--brand-dark))]">
      <p className="flex-1 leading-relaxed text-pretty">
        <span className="font-medium">{"👋 Mirë se vjen!"}</span> Porosit si
        mysafir ose{" "}
        <button className="font-semibold underline underline-offset-2">
          Regjistrohu falas
        </button>{" "}
        ·{" "}
        <button className="font-semibold underline underline-offset-2">
          Hyr
        </button>
      </p>
      <button
        onClick={onClose}
        aria-label="Mbyll njoftimin"
        className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full hover:bg-black/10"
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}
