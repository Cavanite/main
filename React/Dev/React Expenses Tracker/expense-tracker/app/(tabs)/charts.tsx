import React, { useCallback, useEffect, useMemo, useState } from "react";
import { SafeAreaView, View, Text, StyleSheet, Dimensions, FlatList } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { PieChart } from "react-native-chart-kit";

type ExpenseItem = {
  id: string;
  title: string;
  amount: number;
  category: string;
  date: string; // ISO
};

const DEFAULT_CURRENCY = "EUR";
const formatCurrency = (code: string) =>
  new Intl.NumberFormat("nl-NL", { style: "currency", currency: code });

const screenWidth = Dimensions.get("window").width;

export default function ChartsScreen() {
  const [items, setItems] = useState<ExpenseItem[]>([]);
  const [currency, setCurrency] = useState<string>(DEFAULT_CURRENCY);

  useEffect(() => {
    (async () => {
      const saved = await AsyncStorage.getItem("expenses:v1");
      if (saved) {
        try {
          const parsed = JSON.parse(saved) as { items?: ExpenseItem[]; currency?: string };
          setItems(Array.isArray(parsed.items) ? parsed.items : []);
          setCurrency(parsed.currency ?? DEFAULT_CURRENCY);
        } catch {
          setItems([]);
          setCurrency(DEFAULT_CURRENCY);
        }
      }
    })();
  }, []);

  const byCategory = useMemo(() => {
    const map = new Map<string, number>();
    for (const it of items) map.set(it.category, (map.get(it.category) ?? 0) + it.amount);
    return [...map.entries()]
      .map(([name, amount], i) => ({
        name,
        amount,
        population: amount,
        color: DEFAULT_COLORS[i % DEFAULT_COLORS.length],
        legendFontColor: "#ffffff",
        legendFontSize: 12,
      }))
      .sort((a, b) => b.amount - a.amount);
  }, [items]);

  const total = useMemo(() => items.reduce((s, x) => s + x.amount, 0), [items]);

  const ListHeader = (
    <View>
      <Text style={[styles.header, { paddingHorizontal: 8 }]}>Spending by Category</Text>
      {byCategory.length > 0 && (
        <>
          <View style={styles.chartCard}>
            <PieChart
              data={byCategory}
              width={screenWidth - 40}
              height={260}
              accessor="population"
              backgroundColor="transparent"
              paddingLeft="30"
              hasLegend
              chartConfig={{
                backgroundColor: "#1b1b1b",
                backgroundGradientFrom: "#1b1b1b",
                backgroundGradientTo: "#1b1b1b",
                decimalPlaces: 2,
                color: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
                labelColor: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
              }}
              center={[0, 0]}
            />
          </View>

          <View style={styles.totalRow}>
            <Text style={styles.totalLabel}>Total</Text>
            <Text style={styles.totalValue}>{formatCurrency(currency).format(total)}</Text>
          </View>
        </>
      )}
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {byCategory.length === 0 ? (
        <Text style={styles.empty}>No data yet. Add some expenses on Home.</Text>
      ) : (
        <FlatList
          data={byCategory}
          keyExtractor={(item) => item.name}
          ListHeaderComponent={ListHeader}
          renderItem={({ item }) => (
            <View style={styles.rowItem}>
              <Text style={styles.cat}>{item.name}</Text>
              <Text style={styles.amt}>{formatCurrency(currency).format(item.amount)}</Text>
            </View>
          )}
          contentContainerStyle={{ paddingBottom: 16 }}
        />
      )}
    </SafeAreaView>
  );
}

const DEFAULT_COLORS = [
  "#8e44ad", "#3498db", "#2ecc71", "#f1c40f", "#e67e22",
  "#e74c3c", "#1abc9c", "#9b59b6", "#34495e", "#fd79a8",
];

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#111", paddingHorizontal: 16, paddingTop: 8 },
  header: { color: "white", fontSize: 22, fontWeight: "800", marginVertical: 12 },
  chartCard: { backgroundColor: "#1b1b1b", borderRadius: 16, padding: 12, marginBottom: 12, alignItems: "center" },
  totalRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    backgroundColor: "#1b1b1b",
    borderRadius: 16,
    padding: 16,
    marginBottom: 8,
  },
  totalLabel: { color: "#aaa", fontSize: 14 },
  totalValue: { color: "white", fontSize: 18, fontWeight: "700" },
  rowItem: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "#1b1b1b",
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 16,
    marginBottom: 8,
  },
  cat: { color: "white", fontSize: 16, fontWeight: "600" },
  amt: { color: "white", fontSize: 16, fontWeight: "600" },
  empty: { color: "#888", marginTop: 24, textAlign: "center" },
});
