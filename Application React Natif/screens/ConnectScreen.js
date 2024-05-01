import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text } from 'react-native'
import { useNavigation } from '@react-navigation/native'
export default function ConnectScreen() {
  const navigation = useNavigation()

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Connexion</Text>
      <Button
        onPress={() => {
          console.log('SKIPPED CONNECTION')
          navigation.navigate('AccueilScreen', { id: 6 })
        }}
        title="Connexion"
      />
    </View>
  )
}
