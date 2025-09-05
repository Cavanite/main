import { StyleSheet, View } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import { ExternalLink } from '@/components/ExternalLink';
import { IconSymbol } from '@/components/ui/IconSymbol';

export default function ContactScreen() {
  return (
    <ThemedView style={styles.container}>
      <IconSymbol
        size={100}
        color="#808080"
        name="envelope"
        style={styles.icon}
      />
      <ThemedText type="title" style={styles.title}>
        Contact Us
      </ThemedText>
      <ThemedText style={styles.text}>
        We'd love to hear from you! Reach out to us using the information below.
      </ThemedText>
      <View style={styles.infoContainer}>
        <ThemedText type="defaultSemiBold">Email:</ThemedText>
        <ExternalLink href="mailto:bertdezeeuw@live.nl">
          <ThemedText type="link">bertdezeeuw@live.nl</ThemedText>
        </ExternalLink>
      </View>
      <View style={styles.infoContainer}>
        <ThemedText type="defaultSemiBold">Phone:</ThemedText>
        <ThemedText>+31 615482867</ThemedText>
      </View>
      <View style={styles.infoContainer}>
        <ThemedText type="defaultSemiBold">GitHub:</ThemedText>
        <ExternalLink href="https://github.com/Cavanite/">
          <ThemedText type="link">github.com/Cavanite</ThemedText>
        </ExternalLink>
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  icon: {
    marginBottom: 24,
  },
  title: {
    marginBottom: 16,
  },
  text: {
    textAlign: 'center',
    marginBottom: 24,
  },
  infoContainer: {
    width: '100%',
    marginBottom: 16,
    alignItems: 'flex-start',
  },
});
