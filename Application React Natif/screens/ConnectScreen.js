import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text, TextInput } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import {SafeAreaView, StyleSheet} from 'react-native';
import { useState, useEffect } from 'react'

export default function ConnectScreen() {
  const navigation = useNavigation()
  const [login, setLogin] = useState()
  const [mdp, setMdp] = useState()
  const link = 'http://192.168.56.1/api/authentification.php'
  
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text style={{fontSize:50}}>Connexion</Text>
      <TextInput style={styles.input} placeholder='Mail' onChangeText={setLogin}></TextInput>
      <TextInput style={styles.input} placeholder='Mot de passe' onChangeText={setMdp}></TextInput>
      <Button
        onPress={() => {
          console.log('SKIPPED CONNECTION')
          navigation.navigate('AccueilScreen', { id: 6 })
        }}
        title="Se Connecter"
      />
    </View>
  )
}

const styles = StyleSheet.create({
  input: {
    height: 40,
    width: 250,
    margin: 12,
    borderWidth: 1,
    padding: 10
  },
});