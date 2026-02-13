import { useEffect, useState, useCallback } from "react";
import { Text, View, Image, StyleSheet, ScrollView, ActivityIndicator, Switch } from "react-native";
import Animated from "react-native-reanimated";
import { useLocalSearchParams } from "expo-router";

interface PokemonDetails {
    name: string;
    id: number;
    height: number;
    weight: number;
    sprites: {
        front_default: string;
        front_shiny: string;
        back_default: string;
        back_shiny: string;
    };
    types: {
        type: {
            name: string;
        };
    }[];
    stats: {
        base_stat: number;
        stat: {
            name: string;
        };
    }[];
    abilities: {
        ability: {
            name: string;
        };
    }[];
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

export default function Details() {
    const { name } = useLocalSearchParams();
    const [pokemon, setPokemon] = useState<PokemonDetails | null>(null);
    const [loading, setLoading] = useState(true);
    const [weaknesses, setWeaknesses] = useState<string[]>([]);
    const [showMega, setShowMega] = useState(false);
    const [megaForms, setMegaForms] = useState<any[]>([]);
    const [currentMegaIndex, setCurrentMegaIndex] = useState(0);
    const [showPrimal, setShowPrimal] = useState(false);
    const [primalForms, setPrimalForms] = useState<any[]>([]);
    const [currentPrimalIndex, setCurrentPrimalIndex] = useState(0);

    const fetchPokemonDetails = useCallback(async () => {
        try {
            setLoading(true);
            const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${name}`);
            const data = await response.json();
            setPokemon(data);

            // Fetch type effectiveness for weaknesses
            await fetchWeaknesses(data.types);

            // Fetch mega evolution and primal forms data
            await fetchAlternateForms(data.species.url);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    }, [name]);

    const fetchAlternateForms = async (speciesUrl: string) => {
        try {
            const response = await fetch(speciesUrl);
            const speciesData = await response.json();

            const megaVarieties = [];
            const primalVarieties = [];

            for (const variety of speciesData.varieties) {
                if (variety.pokemon.name.includes('mega')) {
                    const pokemonResponse = await fetch(variety.pokemon.url);
                    const pokemonData = await pokemonResponse.json();
                    megaVarieties.push(pokemonData);
                } else if (variety.pokemon.name.includes('primal')) {
                    const pokemonResponse = await fetch(variety.pokemon.url);
                    const pokemonData = await pokemonResponse.json();
                    primalVarieties.push(pokemonData);
                }
            }

            setMegaForms(megaVarieties);
            setPrimalForms(primalVarieties);
        } catch (error) {
            console.error("Error fetching alternate forms:", error);
        }
    };

    const fetchWeaknesses = async (types: any[]) => {
        try {
            const typeEffectiveness: { [key: string]: number } = {};

            for (const typeInfo of types) {
                const response = await fetch(typeInfo.type.url);
                const typeData = await response.json();

                // Double damage from (weaknesses)
                typeData.damage_relations.double_damage_from.forEach((type: any) => {
                    typeEffectiveness[type.name] = (typeEffectiveness[type.name] || 1) * 2;
                });

                // Half damage from (resistances)
                typeData.damage_relations.half_damage_from.forEach((type: any) => {
                    typeEffectiveness[type.name] = (typeEffectiveness[type.name] || 1) * 0.5;
                });

                // No damage from (immunities)
                typeData.damage_relations.no_damage_from.forEach((type: any) => {
                    typeEffectiveness[type.name] = 0;
                });
            }

            // Filter only weaknesses (2x or 4x damage)
            const weak = Object.entries(typeEffectiveness)
                .filter(([_, multiplier]) => multiplier >= 2)
                .map(([type, _]) => type);

            setWeaknesses(weak);
        } catch (error) {
            console.error("Error fetching weaknesses:", error);
        }
    };

    useEffect(() => {
        fetchPokemonDetails();
    }, [fetchPokemonDetails]);

    if (loading) {
        return (
            <View style={styles.container}>
                <ActivityIndicator size="large" color="#0000ff" />
            </View>
        );
    }

    if (!pokemon) {
        return (
            <View style={styles.container}>
                <Text>Pokemon not found</Text>
            </View>
        );
    }

    const primaryType = pokemon.types[0]?.type.name;
    const backgroundColor = colorsByType[primaryType] || "#A8A878";

    return (
        <ScrollView
            style={{ flex: 1, backgroundColor: backgroundColor + "40" }}
            contentContainerStyle={styles.scrollContent}
            showsVerticalScrollIndicator={true}
        >
            <View style={styles.header}>
                <Text style={styles.name}>{pokemon.name}</Text>
                <Text style={styles.id}>#{pokemon.id.toString().padStart(3, "0")}</Text>
            </View>

            <View style={styles.typesContainer}>
                {pokemon.types.map((type) => (
                    <Text
                        key={type.type.name}
                        style={[styles.type, { backgroundColor: colorsByType[type.type.name] }]}
                    >
                        {type.type.name}
                    </Text>
                ))}
            </View>

            {megaForms.length > 0 && (
                <View style={styles.megaToggleContainer}>
                    <Text style={styles.megaToggleLabel}>Show Mega Evolution</Text>
                    <Switch
                        value={showMega}
                        onValueChange={(value) => {
                            setShowMega(value);
                            setShowPrimal(false);
                            setCurrentMegaIndex(0);
                        }}
                        trackColor={{ false: "#767577", true: "#81b0ff" }}
                        thumbColor={showMega ? "#007AFF" : "#f4f3f4"}
                    />
                </View>
            )}

            {primalForms.length > 0 && (
                <View style={styles.primalToggleContainer}>
                    <Text style={styles.primalToggleLabel}>Show Primal Form</Text>
                    <Switch
                        value={showPrimal}
                        onValueChange={(value) => {
                            setShowPrimal(value);
                            setShowMega(false);
                            setCurrentPrimalIndex(0);
                        }}
                        trackColor={{ false: "#767577", true: "#FF6B35" }}
                        thumbColor={showPrimal ? "#FF4500" : "#f4f3f4"}
                    />
                </View>
            )}

            <View style={styles.spritesContainer}>
                <View>
                    <Text style={styles.spriteLabel}>
                        {showMega && megaForms.length > 0
                            ? "Mega Normal"
                            : showPrimal && primalForms.length > 0
                                ? "Primal Normal"
                                : "Normal"}
                    </Text>
                    <Image
                        source={{
                            uri: showMega && megaForms.length > 0
                                ? megaForms[currentMegaIndex].sprites.front_default
                                : showPrimal && primalForms.length > 0
                                    ? primalForms[currentPrimalIndex].sprites.front_default
                                    : pokemon.sprites.front_default
                        }}
                        style={[styles.sprite, { borderColor: colorsByType[pokemon.types[0].type.name] }]}
                    />
                </View>
                <View>
                    <Text style={styles.spriteLabel}>
                        {showMega && megaForms.length > 0
                            ? "Mega Shiny"
                            : showPrimal && primalForms.length > 0
                                ? "Primal Shiny"
                                : "Shiny"}
                    </Text>
                    <Image
                        source={{
                            uri: showMega && megaForms.length > 0
                                ? megaForms[currentMegaIndex].sprites.front_shiny
                                : showPrimal && primalForms.length > 0
                                    ? primalForms[currentPrimalIndex].sprites.front_shiny
                                    : pokemon.sprites.front_shiny
                        }}
                        style={[styles.sprite, { borderColor: colorsByType[pokemon.types[0].type.name] }]}
                    />
                </View>
            </View>

            <View style={styles.infoContainer}>
                <View style={styles.infoBox}>
                    <Text style={styles.infoLabel}>Height</Text>
                    <Text style={styles.infoValue}>{pokemon.height / 10} m</Text>
                </View>
                <View style={styles.infoBox}>
                    <Text style={styles.infoLabel}>Weight</Text>
                    <Text style={styles.infoValue}>{pokemon.weight / 10} kg</Text>
                </View>
            </View>

            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Abilities</Text>
                <View style={styles.abilitiesContainer}>
                    {pokemon.abilities.map((ability) => (
                        <Text key={ability.ability.name} style={styles.ability}>
                            {ability.ability.name}
                        </Text>
                    ))}
                </View>
            </View>

            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Base Stats</Text>
                {pokemon.stats.map((stat) => (
                    <View key={stat.stat.name} style={styles.statRow}>
                        <Text style={styles.statName}>{stat.stat.name}</Text>
                        <Text style={styles.statValue}>{stat.base_stat}</Text>
                        <View style={styles.statBar}>
                            <View
                                style={[
                                    styles.statBarFill,
                                    { width: `${(stat.base_stat / 255) * 100}%`, backgroundColor }
                                ]}
                            />
                        </View>
                    </View>
                ))}
            </View>
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Weaknesses</Text>
                {weaknesses.length > 0 ? (
                    <View style={styles.weaknessesContainer}>
                        {weaknesses.map((weakness) => (
                            <Text
                                key={weakness}
                                style={[styles.weakness, { backgroundColor: colorsByType[weakness] || "#A8A878" }]}
                            >
                                {weakness}
                            </Text>
                        ))}
                    </View>
                ) : (
                    <Text style={styles.noWeakness}>No major weaknesses</Text>
                )}
            </View>
        </ScrollView>
    );
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
    },
    scrollContent: {
        padding: 20,
        paddingBottom: 150,
        flexGrow: 1,
    },
    header: {
        alignItems: "center",
        marginBottom: 20,
    },
    name: {
        fontSize: 36,
        fontWeight: "bold",
        textTransform: "capitalize",
        marginBottom: 5,
    },
    id: {
        fontSize: 24,
        color: "#666",
        fontWeight: "600",
    },
    typesContainer: {
        flexDirection: "row",
        justifyContent: "center",
        gap: 10,
        marginBottom: 20,
    },
    megaToggleContainer: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#fff",
        padding: 15,
        borderRadius: 10,
        marginHorizontal: 20,
        marginBottom: 20,
        gap: 10,
    },
    megaToggleLabel: {
        fontSize: 16,
        fontWeight: "600",
    },
    primalToggleContainer: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#FFE5D9",
        padding: 15,
        borderRadius: 10,
        marginHorizontal: 20,
        marginBottom: 20,
        gap: 10,
        borderWidth: 2,
        borderColor: "#FF6B35",
    },
    primalToggleLabel: {
        fontSize: 16,
        fontWeight: "700",
        color: "#FF4500",
    },
    type: {
        fontSize: 16,
        fontWeight: "600",
        textAlign: "center",
        paddingHorizontal: 20,
        paddingVertical: 8,
        borderRadius: 20,
        color: "#fff",
        textTransform: "capitalize",
    },
    spritesContainer: {
        flexDirection: "row",
        justifyContent: "space-around",
        marginBottom: 20,
    },
    spriteLabel: {
        fontSize: 16,
        fontWeight: "600",
        textAlign: "center",
        marginBottom: 5,
    },
    sprite: {
        width: 150,
        height: 150,
        borderWidth: 2,
        borderRadius: 8,
    },
    infoContainer: {
        flexDirection: "row",
        justifyContent: "space-around",
        marginBottom: 30,
    },
    infoBox: {
        alignItems: "center",
        backgroundColor: "#fff",
        padding: 15,
        borderRadius: 10,
        minWidth: 120,
    },
    infoLabel: {
        fontSize: 14,
        color: "#666",
        marginBottom: 5,
    },
    infoValue: {
        fontSize: 20,
        fontWeight: "bold",
    },
    section: {
        marginBottom: 30,
    },
    sectionTitle: {
        fontSize: 24,
        fontWeight: "bold",
        marginBottom: 15,
    },
    abilitiesContainer: {
        flexDirection: "row",
        flexWrap: "wrap",
        gap: 10,
    },
    ability: {
        fontSize: 16,
        backgroundColor: "#fff",
        paddingHorizontal: 15,
        paddingVertical: 8,
        borderRadius: 15,
        textTransform: "capitalize",
    },
    statRow: {
        flexDirection: "row",
        alignItems: "center",
        marginBottom: 10,
    },
    statName: {
        fontSize: 14,
        textTransform: "capitalize",
        width: 120,
        fontWeight: "500",
    },
    statValue: {
        fontSize: 14,
        fontWeight: "bold",
        width: 40,
        textAlign: "right",
    },
    statBar: {
        flex: 1,
        height: 8,
        backgroundColor: "#e0e0e0",
        borderRadius: 4,
        marginLeft: 10,
        overflow: "hidden",
    },
    statBarFill: {
        height: "100%",
        borderRadius: 4,
    },
    weaknessesContainer: {
        flexDirection: "row",
        flexWrap: "wrap",
        gap: 10,
    },
    weakness: {
        fontSize: 16,
        fontWeight: "600",
        color: "#fff",
        paddingHorizontal: 15,
        paddingVertical: 8,
        borderRadius: 15,
        textTransform: "capitalize",
    },
    noWeakness: {
        fontSize: 16,
        color: "#666",
        fontStyle: "italic",
    },
});