import { useMemo, useState } from "react";

import { BottomNav, type PageId } from "./components/BottomNav";
import { PermissionModal } from "./components/PermissionModal";
import { TopBanner } from "./components/TopBanner";
import { HomePage } from "./pages/HomePage";
import { OrdersPage } from "./pages/OrdersPage";
import { CartPage } from "./pages/CartPage";
import { AboutPage } from "./pages/AboutPage";
import { ProfilePage } from "./pages/ProfilePage";
import { stores, type Store } from "./data";

export type CartLine = {
  storeId: string;
  storeName: string;
  name: string;
  price: number;
  qty: number;
};

function TiliGoApp() {
  const [page, setPage] = useState<PageId>("home");
  const [showPermission, setShowPermission] = useState(true);
  const [showBanner, setShowBanner] = useState(true);
  const [cart, setCart] = useState<CartLine[]>([]);

  const cartCount = useMemo(
    () => cart.reduce((sum, line) => sum + line.qty, 0),
    [cart],
  );

  function addSampleFromStore(store: Store) {
    setCart((prev) => {
      const existing = prev.find((l) => l.storeId === store.id);
      if (existing) {
        return prev.map((l) =>
          l.storeId === store.id ? { ...l, qty: l.qty + 1 } : l,
        );
      }
      return [
        ...prev,
        {
          storeId: store.id,
          storeName: store.name,
          name: `Porosi nga ${store.name}`,
          price: Math.max(store.minOrder, 5),
          qty: 1,
        },
      ];
    });
    setPage("cart");
  }

  function updateQty(index: number, delta: number) {
    setCart((prev) =>
      prev
        .map((line, i) =>
          i === index ? { ...line, qty: line.qty + delta } : line,
        )
        .filter((line) => line.qty > 0),
    );
  }

  return (
    <div className="relative mx-auto flex min-h-screen w-full max-w-md flex-col bg-background">
      {showBanner && <TopBanner onClose={() => setShowBanner(false)} />}

      <main className="flex-1 pb-24">
        {page === "home" && (
          <HomePage stores={stores} onOrder={addSampleFromStore} />
        )}
        {page === "orders" && <OrdersPage />}
        {page === "cart" && (
          <CartPage
            cart={cart}
            onUpdateQty={updateQty}
            onBrowse={() => setPage("home")}
          />
        )}
        {page === "about" && <AboutPage />}
        {page === "profile" && <ProfilePage />}
      </main>

      <BottomNav active={page} onChange={setPage} cartCount={cartCount} />

      {showPermission && (
        <PermissionModal
          onAllow={() => setShowPermission(false)}
          onDismiss={() => setShowPermission(false)}
        />
      )}
    </div>
  );
}

export default TiliGoApp;
