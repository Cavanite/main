import { HeaderBackButton } from "@react-navigation/elements";
import { Stack } from "expo-router";

export default function RootLayout() {
  return <Stack>
    <Stack.Screen name="index" options={{ title: "Home" }} />
    <Stack.Screen
      name="details"
      options={{
        headerBackButtonDisplayMode: "minimal",
        presentation: "card",
      }}
    />
  </Stack>;
}
