import React, { useEffect, useMemo, useState } from "react";
import {
  SafeAreaView,
  View,
  Text,
  TextInput,
  Button,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ListRenderItem,
  Modal,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Picker } from "@react-native-picker/picker";

type ExpenseItem = {
  id: string;
  title: string;
  amount: number;
  category: string;
  date: string; // ISO string
};

const DEFAULT_CURRENCY = "EUR";
const formatCurrency = (code: string) =>
  new Intl.NumberFormat("nl-NL", { style: "currency", currency: code });

const CATEGORY_OPTIONS = [
  "Food",
  "Transport",
  "Groceries",
  "Rent",
  "Bills",
  "Fun",
  "Other",
] as const;

export default function IndexScreen() {
  const [items, setItems] = useState<ExpenseItem[]>([]);
  const [title, setTitle] = useState<string>("");
  const [amount, setAmount] = useState<string>("");
  const [category, setCategory] = useState<string>(CATEGORY_OPTIONS[0]);
  const [currency, setCurrency] = useState<string>(DEFAULT_CURRENCY);

  // Edit modal state
  const [editing, setEditing] = useState<ExpenseItem | null>(null);
  const [editTitle, setEditTitle] = useState<string>("");
  const [editAmount, setEditAmount] = useState<string>("");
  const [editCategory, setEditCategory] = useState<string>(CATEGORY_OPTIONS[0]);

  useEffect(() => {
    (async () => {
      const saved = await AsyncStorage.getItem("expenses:v1");
      if (saved) {
        try {
          const parsed = JSON.parse(saved) as { items?: ExpenseItem[]; currency?: string };
          setItems(Array.isArray(parsed.items) ? parsed.items : []);
          setCurrency(parsed.currency ?? DEFAULT_CURRENCY);
        } catch {}
      }
    })();
  }, []);

  useEffect(() => {
    AsyncStorage.setItem("expenses:v1", JSON.stringify({ items, currency })).catch(() => {});
  }, [items, currency]);

  const total = useMemo(() => items.reduce((sum, x) => sum + x.amount, 0), [items]);

  function addItem() {
    const value = Number((amount || "").replace(",", "."));
    if (!title.trim() || Number.isNaN(value)) {
      Alert.alert("Please enter a name and a numeric amount.");
      return;
    }
    setItems((prev) => [
      { id: Date.now().toString(), title: title.trim(), amount: value, category, date: new Date().toISOString() },
      ...prev,
    ]);
    setTitle("");
    setAmount("");
    setCategory(CATEGORY_OPTIONS[0]);
  }

  function deleteItem(id: string) {
    setItems((prev) => prev.filter((x) => x.id !== id));
  }

  function clearAll() {
    Alert.alert("Clear all expenses?", "This cannot be undone.", [
      { text: "Cancel", style: "cancel" },
      { text: "Clear", style: "destructive", onPress: () => setItems([]) },
    ]);
  }

  // Edit
  function openEditModal(item: ExpenseItem) {
    setEditing(item);
    setEditTitle(item.title);
    setEditAmount(String(item.amount));
    setEditCategory(item.category);
  }
  function saveEdit() {
    if (!editing) return;
    const value = Number((editAmount || "").replace(",", "."));
    if (!editTitle.trim() || Number.isNaN(value)) {
      Alert.alert("Please enter a name and a numeric amount.");
      return;
    }
    setItems((prev) =>
      prev.map((x) => (x.id === editing.id ? { ...x, title: editTitle.trim(), amount: value, category: editCategory } : x))
    );
    setEditing(null);
  }
  function deleteFromEdit() {
    if (!editing) return;
    const id = editing.id;
    setEditing(null);
    setItems((prev) => prev.filter((x) => x.id !== id));
  }

  const renderItem: ListRenderItem<ExpenseItem> = ({ item }) => (
    <TouchableOpacity onPress={() => openEditModal(item)} activeOpacity={0.8}>
      <View style={styles.listItem}>
        <View style={{ flex: 1 }}>
          <Text style={styles.itemTitle}>{item.title}</Text>
          <Text style={styles.itemMeta}>
            {item.category} • {new Date(item.date).toLocaleDateString()}
          </Text>
        </View>
        <View style={styles.right}>
          <Text style={styles.itemAmount}>{formatCurrency(currency).format(item.amount)}</Text>
          <TouchableOpacity onPress={() => deleteItem(item.id)}>
            <Text style={styles.delete}>Delete</Text>
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );

  // 👉 Everything (form + totals) goes into ListHeaderComponent so the whole page scrolls
  const ListHeader = (
    <View>
      <View style={{ paddingHorizontal: 16 }}>
        <Text style={styles.header}>Money Tracker 💸</Text>
      </View>

      <View style={styles.card}>
        <TextInput
          style={styles.input}
          placeholder="What did you buy?"
          value={title}
          onChangeText={setTitle}
          returnKeyType="next"
        />
        <TextInput
          style={styles.input}
          placeholder="Amount (e.g. 12.50)"
          keyboardType="decimal-pad"
          value={amount}
          onChangeText={setAmount}
        />
        <View style={styles.pickerWrap}>
          <Text style={styles.pickerLabel}>Category</Text>
          <Picker
            selectedValue={category}
            onValueChange={(val) => setCategory(String(val))}
            style={styles.picker}
            dropdownIconColor="#ddd"
          >
            {CATEGORY_OPTIONS.map((c) => (
              <Picker.Item label={c} value={c} key={c} />
            ))}
          </Picker>
        </View>

        <Button title="Add Expense" onPress={addItem} />
      </View>

      <View style={styles.row}>
        <View style={styles.totalCard}>
          <Text style={styles.totalLabel}>Total</Text>
          <Text style={styles.totalValue}>{formatCurrency(currency).format(total)}</Text>
        </View>
        <View style={styles.actions}>
          <Button title="Clear All" color="#ff6b6b" onPress={clearAll} />
        </View>
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView behavior={Platform.select({ ios: "padding", android: undefined })} style={{ flex: 1 }}>
        <FlatList
          data={items}
          keyExtractor={(x) => x.id}
          renderItem={renderItem}
          ListHeaderComponent={ListHeader}
          ListEmptyComponent={<Text style={styles.empty}>No expenses yet. Add your first one!</Text>}
          contentContainerStyle={{ paddingBottom: 24 }}
          keyboardShouldPersistTaps="handled"
        />
      </KeyboardAvoidingView>

      {/* Edit Modal */}
      <Modal visible={!!editing} animationType="slide" transparent>
        <View style={styles.modalBackdrop}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>Edit Expense</Text>

            <TextInput style={styles.input} placeholder="Title" value={editTitle} onChangeText={setEditTitle} />
            <TextInput
              style={styles.input}
              placeholder="Amount"
              keyboardType="decimal-pad"
              value={editAmount}
              onChangeText={setEditAmount}
            />
            <View style={styles.pickerWrap}>
              <Text style={styles.pickerLabel}>Category</Text>
              <Picker
                selectedValue={editCategory}
                onValueChange={(v) => setEditCategory(String(v))}
                style={styles.picker}
                dropdownIconColor="#ddd"
              >
                {CATEGORY_OPTIONS.map((c) => (
                  <Picker.Item label={c} value={c} key={c} />
                ))}
              </Picker>
            </View>

            <View style={{ height: 8 }} />
            <View style={styles.modalButtons}>
              <View style={{ flex: 1, marginRight: 8 }}>
                <Button title="Cancel" onPress={() => setEditing(null)} />
              </View>
              <View style={{ flex: 1, marginLeft: 8 }}>
                <Button title="Save" onPress={saveEdit} />
              </View>
            </View>
            <View style={{ height: 8 }} />
            <Button title="Delete" color="#ff6b6b" onPress={deleteFromEdit} />
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#111", paddingHorizontal: 16 },
  header: { fontSize: 28, fontWeight: "800", color: "white", marginTop: 16, marginBottom: 8 },
  card: { backgroundColor: "#1b1b1b", borderRadius: 16, padding: 16, gap: 10, marginBottom: 12 },
  input: {
    backgroundColor: "#222",
    color: "white",
    padding: 12,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#333",
  },
  pickerWrap: { backgroundColor: "#222", borderRadius: 12, borderWidth: 1, borderColor: "#333", overflow: "hidden" },
  pickerLabel: { color: "#aaa", fontSize: 12, paddingTop: 8, paddingLeft: 12 },
  picker: { color: "white", marginTop: -12 },
  row: { flexDirection: "row", gap: 8, marginBottom: 8 },
  totalCard: { flex: 1, backgroundColor: "#1b1b1b", borderRadius: 16, padding: 16, justifyContent: "center" },
  totalLabel: { color: "#aaa", fontSize: 14 },
  totalValue: { color: "white", fontSize: 20, fontWeight: "700" },
  actions: { width: 120, justifyContent: "center" },
  listItem: {
    flexDirection: "row",
    justifyContent: "space-between",
    backgroundColor: "#1b1b1b",
    padding: 16,
    borderRadius: 16,
    marginTop: 8,
    alignItems: "center",
    gap: 12,
  },
  itemTitle: { color: "white", fontSize: 16, fontWeight: "600" },
  itemMeta: { color: "#999", fontSize: 12, marginTop: 2 },
  right: { alignItems: "flex-end" },
  itemAmount: { color: "white", fontSize: 16, fontWeight: "700" },
  delete: { color: "#ff6b6b", marginTop: 6, fontWeight: "600" },
  empty: { color: "#888", textAlign: "center", marginVertical: 12 },

  // Modal
  modalBackdrop: { flex: 1, backgroundColor: "rgba(0,0,0,0.6)", justifyContent: "center", paddingHorizontal: 16 },
  modalCard: { backgroundColor: "#1b1b1b", borderRadius: 16, padding: 16 },
  modalTitle: { color: "white", fontSize: 18, fontWeight: "700", marginBottom: 12 },
  modalButtons: { flexDirection: "row" },
});
