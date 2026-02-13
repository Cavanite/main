import { useEffect, useState } from "react";
import { Text, View, Image, StyleSheet, Pressable, ActivityIndicator, TextInput } from "react-native";
import Animated from "react-native-reanimated";
import { router } from 'expo-router';

interface Pokemon {
  name: string;
  url: string;
  image?: string;
  shinyImage?: string;
  types?: PokemonType[];
}
interface PokemonType {
  type: {
    name: string;
    url: string;
  }
}

const colorsByType: { [key: string]: string } = {
  grass: "#78C850",
  fire: "#F08030",
  water: "#6890F0",
  bug: "#A8B820",
  normal: "#A8A878",
  poison: "#A040A0",
  electric: "#F8D030",
  ground: "#E0C068",
  fairy: "#EE99AC",
  fighting: "#C03028",
  psychic: "#F85888",
  rock: "#B8A038",
  ghost: "#705898",
  ice: "#98D8D8",
  dragon: "#7038F8",
  dark: "#705848",
  steel: "#B8B8D0",
  flying: "#A890F0",
};

export default function Index() {
  const [allPokemons, setAllPokemons] = useState<Pokemon[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [displayCount, setDisplayCount] = useState(20);
  const DISPLAY_INCREMENT = 20;

  const filteredPokemons = allPokemons.filter(pokemon =>
    pokemon.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const displayedPokemons = searchQuery
    ? filteredPokemons.slice(0, 50) // Show up to 50 search results
    : filteredPokemons.slice(0, displayCount);

  useEffect(() => {
    fetchAllPokemonNames();
  }, [])

  const fetchPokemonDetails = async (pokemon: Pokemon) => {
    const res = await fetch(pokemon.url);
    const details = await res.json();
    return {
      name: pokemon.name,
      url: pokemon.url,
      image: details.sprites.front_default,
      shinyImage: details.sprites.front_shiny,
      types: details.types,
    };
  };

  const updatePokemonWithDetails = (allPokemons: Pokemon[], fetchedDetails: Pokemon[]) => {
    return allPokemons.map(p => {
      const updated = fetchedDetails.find(d => d.name === p.name);
      return updated || p;
    });
  };

  useEffect(() => {
    async function fetchDetailsForDisplayed() {
      const pokemonsNeedingDetails = displayedPokemons.filter(p => !p.image);

      if (pokemonsNeedingDetails.length === 0) return;

      try {
        const detailsPromises = pokemonsNeedingDetails.map(fetchPokemonDetails);
        const fetchedDetails = await Promise.all(detailsPromises);
        setAllPokemons(prev => updatePokemonWithDetails(prev, fetchedDetails));
      } catch (error) {
        console.log(error);
      }
    }

    fetchDetailsForDisplayed();
  }, [displayedPokemons]);

  async function fetchAllPokemonNames() {
    try {
      setLoading(true);
      const response = await fetch(`https://pokeapi.co/api/v2/pokemon?limit=1025`);
      const data = await response.json();
      setAllPokemons(data.results);
    } catch (error) {
      console.log(error);
    } finally {
      setLoading(false);
    }
  }

  function loadMore() {
    setDisplayCount(prev => prev + DISPLAY_INCREMENT);
  }

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text style={styles.loadingText}>Loading Pokémon...</Text>
      </View>
    );
  }

  return (
    <Animated.ScrollView>
      <View style={styles.searchContainer}>
        <TextInput
          placeholderTextColor="#00000080"
          style={styles.searchInput}
          placeholder="Search Pokemon..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>
      <View>
        {displayedPokemons.map((pokemon) => {
          // Show loading placeholder if details haven't loaded yet
          if (!pokemon.image || !pokemon.types) {
            return (
              <View key={pokemon.name} style={{ padding: 20, alignItems: "center" }}>
                <Text style={styles.name}>{pokemon.name}</Text>
                <ActivityIndicator size="small" color="#0000ff" />
              </View>
            );
          }

          return (
            <Pressable key={pokemon.name} onPress={() => router.push(`/details?name=${pokemon.name}`)}>
              <View>

                <View style={{ flexDirection: "column", marginBottom: 10, padding: 10, backgroundColor: "#bc9090" + 30, borderRadius: 20, marginHorizontal: 10, marginTop: 10 }}>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.name}>{pokemon.name}</Text>
                    <View style={{ flexDirection: "row", flexWrap: "wrap" }}>
                      {pokemon.types.map((type) => (
                        <Text key={type.type.name} style={[styles.type, { backgroundColor: colorsByType[type.type.name] }]}>{type.type.name}</Text>
                      ))}


                    </View>
                  </View>


                  <View style={{ flexDirection: "row", justifyContent: "center", marginTop: 10 }}>
                    <Image source={{ uri: pokemon.image }} style={{ width: 125, height: 125 }} />
                    <Image source={{ uri: pokemon.shinyImage }} style={{ width: 125, height: 125 }} />
                  </View>

                </View>

              </View>
            </Pressable>
          );
        })}

        {!searchQuery && displayCount < filteredPokemons.length && (
          <View style={styles.loadMoreContainer}>
            <Pressable style={styles.loadMoreButton} onPress={loadMore}>
              <Text style={styles.loadMoreText}>Load More Pokémon</Text>
            </Pressable>
          </View>
        )}
      </View>
    </Animated.ScrollView>
  );
}

const styles = StyleSheet.create({
  searchContainer: {
    padding: 10,
  },
  searchInput: {
    backgroundColor: "#fff",
    padding: 15,
    borderRadius: 10,
    fontSize: 16,
    borderWidth: 1,
    borderColor: "#000000",
    textShadowColor: "#000",
  },
  name: {
    fontSize: 28,
    fontWeight: "bold",
    textAlign: "center",
    textTransform: "capitalize",
  },
  type: {
    fontSize: 16,
    marginLeft: 5,
    fontWeight: "500",
    textAlign: "center",
    alignSelf: "center",
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 10,
    color: "#fff",
    marginTop: 5,
    textTransform: "capitalize",
  },
  header: {
    fontSize: 32,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 20,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: "#666",
  },
  loadMoreContainer: {
    padding: 20,
    alignItems: "center",
  },
  loadMoreButton: {
    backgroundColor: "#007AFF",
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 10,
  },
  loadMoreText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
});