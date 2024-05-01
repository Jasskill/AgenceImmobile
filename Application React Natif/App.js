import { NavigationContainer } from '@react-navigation/native'
import AccueilScreen from './screens/AccueilScreen'
import ConnectScreen from './screens/ConnectScreen'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import PiecesScreen from './screens/PiecesScreen'
import PieceDetailsScreen from './screens/PieceDetailsScreen'
const Stack = createNativeStackNavigator()
export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Homepage"
          component={ConnectScreen}
          options={{
            headerShown: false,
          }}
        />

        <Stack.Screen
          name="AccueilScreen"
          component={AccueilScreen}
          options={{
            headerShown: true,
          }}
        />

        <Stack.Screen
          name="PiecesScreen"
          component={PiecesScreen}
          options={{
            headerShown: true,
          }}
        />

<Stack.Screen
          name="PieceDetailsScreen"
          component={PieceDetailsScreen}
          options={{
            headerShown: true,
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  )
}

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: '#fff',
//     alignItems: 'center',
//     justifyContent: 'center',
//   },
// })
