export type Category = {
  id: string;
  label: string;
  emoji: string;
};

export type Store = {
  id: string;
  name: string;
  categoryId: string;
  categoryLabel: string;
  image: string;
  rating: number;
  deliveryMinutes: number;
  deliveryFee: number;
  minOrder: number;
  isOpen: boolean;
  tags: string[];
};

export type Product = {
  id: string;
  name: string;
  description: string;
  price: number;
  image: string;
  storeId: string;
};

export type OrderStatus = "duke_u_pergatitur" | "rruges" | "dorezuar";

export type Order = {
  id: string;
  storeName: string;
  storeImage: string;
  items: { name: string; qty: number; price: number }[];
  total: number;
  status: OrderStatus;
  date: string;
  etaMinutes?: number;
};

export const categories: Category[] = [
  { id: "all", label: "Të gjitha", emoji: "🍽️" },
  { id: "pizza", label: "Pica", emoji: "🍕" },
  { id: "burger", label: "Burgera", emoji: "🍔" },
  { id: "sushi", label: "Sushi", emoji: "🍣" },
  { id: "pharmacy", label: "Farmaci", emoji: "💊" },
  { id: "coffee", label: "Kafe", emoji: "☕" },
  { id: "market", label: "Supermarket", emoji: "🛒" },
];

export const quickSearches: { label: string; emoji: string }[] = [
  { label: "Pica e nxehtë", emoji: "🍕" },
  { label: "Burger juicy", emoji: "🍔" },
  { label: "Sushi premium", emoji: "🍣" },
  { label: "Farmaci urgjente", emoji: "💊" },
  { label: "Kafe e mëngjesit", emoji: "☕" },
  { label: "Supermarket", emoji: "🛒" },
];

export const stores: Store[] = [
  {
    id: "freeshop-tili",
    name: "Freeshop Tili",
    categoryId: "market",
    categoryLabel: "Supermarket",
    image: "/images/store-supermarket.png",
    rating: 5.0,
    deliveryMinutes: 30,
    deliveryFee: 1.0,
    minOrder: 5.0,
    isOpen: true,
    tags: ["Falas mbi €20", "Popullor"],
  },
  {
    id: "tili-freeshop",
    name: "Tili Freeshop",
    categoryId: "market",
    categoryLabel: "Supermarket",
    image: "/images/store-supermarket.png",
    rating: 5.0,
    deliveryMinutes: 20,
    deliveryFee: 1.0,
    minOrder: 5.0,
    isOpen: true,
    tags: ["I shpejtë"],
  },
  {
    id: "burger-house",
    name: "Burger House",
    categoryId: "burger",
    categoryLabel: "Burgera",
    image: "/images/store-burger.png",
    rating: 4.8,
    deliveryMinutes: 25,
    deliveryFee: 1.5,
    minOrder: 6.0,
    isOpen: true,
    tags: ["Trend 🔥"],
  },
  {
    id: "pizza-napoli",
    name: "Pizza Napoli",
    categoryId: "pizza",
    categoryLabel: "Pica",
    image: "/images/store-pizza.png",
    rating: 4.9,
    deliveryMinutes: 35,
    deliveryFee: 1.2,
    minOrder: 7.0,
    isOpen: true,
    tags: ["Wood fired"],
  },
  {
    id: "sakura-sushi",
    name: "Sakura Sushi",
    categoryId: "sushi",
    categoryLabel: "Sushi",
    image: "/images/store-sushi.png",
    rating: 4.7,
    deliveryMinutes: 40,
    deliveryFee: 2.0,
    minOrder: 12.0,
    isOpen: true,
    tags: ["Premium"],
  },
  {
    id: "farmacia-plus",
    name: "Farmacia Plus",
    categoryId: "pharmacy",
    categoryLabel: "Farmaci",
    image: "/images/store-pharmacy.png",
    rating: 4.9,
    deliveryMinutes: 15,
    deliveryFee: 1.0,
    minOrder: 3.0,
    isOpen: true,
    tags: ["24/7"],
  },
  {
    id: "morning-coffee",
    name: "Morning Coffee",
    categoryId: "coffee",
    categoryLabel: "Kafe",
    image: "/images/store-coffee.png",
    rating: 4.6,
    deliveryMinutes: 18,
    deliveryFee: 0.9,
    minOrder: 4.0,
    isOpen: false,
    tags: ["Mëngjes"],
  },
];

export const orders: Order[] = [
  {
    id: "TG-2041",
    storeName: "Burger House",
    storeImage: "/images/store-burger.png",
    items: [
      { name: "Double Cheeseburger", qty: 2, price: 4.5 },
      { name: "Patate të skuqura", qty: 1, price: 2.0 },
    ],
    total: 11.0,
    status: "rruges",
    date: "Sot, 14:20",
    etaMinutes: 12,
  },
  {
    id: "TG-2038",
    storeName: "Pizza Napoli",
    storeImage: "/images/store-pizza.png",
    items: [{ name: "Margherita", qty: 1, price: 6.5 }],
    total: 7.7,
    status: "dorezuar",
    date: "Dje, 20:05",
  },
  {
    id: "TG-2033",
    storeName: "Freeshop Tili",
    storeImage: "/images/store-supermarket.png",
    items: [
      { name: "Qumësht 1L", qty: 2, price: 1.1 },
      { name: "Bukë", qty: 1, price: 0.6 },
    ],
    total: 3.8,
    status: "dorezuar",
    date: "12 Maj, 11:40",
  },
];

export function formatEur(value: number): string {
  return `€${value.toFixed(2)}`;
}
