import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import HomeScreen from '../screens/HomeScreen';
import SettingsScreen from '../screens/SettingsScreen';
import LegalHelpScreen from '../screens/LegalHelpScreen';
import { colors } from '../theme';

function AlertScreen() {
    return (
        <View style={styles.placeholder}>
            <Text style={styles.placeholderText}>Alert screen — coming soon</Text>
        </View>
    );
}

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

function MainTabs({ navigation }) {
    const insets = useSafeAreaInsets();

    return (
        <View style={{ flex: 1 }}>
            <Tab.Navigator
                screenOptions={({ route }) => ({
                    headerShown: false,
                    tabBarIcon: ({ color, size }) => {
                        let iconName;
                        if (route.name === 'Home') iconName = 'home';
                        else if (route.name === 'Alert') iconName = 'alert-circle';
                        else if (route.name === 'Settings') iconName = 'settings';
                        return <Ionicons name={iconName} size={size} color={color} />;
                    },
                    tabBarActiveTintColor: colors.brass,
                    tabBarInactiveTintColor: colors.muted,
                })}
            >
                <Tab.Screen name="Home" component={HomeScreen} />
                <Tab.Screen name="Alert" component={AlertScreen} />
                <Tab.Screen name="Settings" component={SettingsScreen} />
            </Tab.Navigator>

            <Pressable
                style={[styles.fab, { bottom: 62 + insets.bottom }]}
                onPress={() => navigation.navigate('LegalHelp')}
            >
                <Ionicons name="chatbubble-ellipses" size={24} color={colors.white} />
            </Pressable>
        </View>
    );
}

export default function AppNavigator() {
    return (
        <NavigationContainer>
            <Stack.Navigator screenOptions={{ headerShown: false }}>
                <Stack.Screen name="MainTabs" component={MainTabs} />
                <Stack.Screen
                    name="LegalHelp"
                    component={LegalHelpScreen}
                    options={{ presentation: 'modal' }}
                />
            </Stack.Navigator>
        </NavigationContainer>
    );
}

const styles = StyleSheet.create({
    placeholder: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: colors.background },
    placeholderText: { fontSize: 16, color: colors.muted },
    fab: {
        position: 'absolute',
        right: 20,
        width: 52,
        height: 52,
        borderRadius: 26,
        backgroundColor: colors.brass,
        justifyContent: 'center',
        alignItems: 'center',
        elevation: 4,
        shadowColor: '#000',
        shadowOpacity: 0.15,
        shadowRadius: 6,
        shadowOffset: { width: 0, height: 2 },
    },
});