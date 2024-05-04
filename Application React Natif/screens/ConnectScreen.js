import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text, TextInput } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { SafeAreaView, StyleSheet } from 'react-native';
import { useState, useEffect } from 'react'
import base64 from 'react-native-base64'

export default function ConnectScreen() {
  const navigation = useNavigation()
  const [login, setLogin] = useState('')
  const [mdp, setMdp] = useState('')

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text style={{ fontSize: 50 }}>Connexion</Text>
      <TextInput style={styles.input} placeholder='Mail' onChangeText={setLogin} autoCapitalize='none'></TextInput>
      <TextInput style={styles.input} placeholder='Mot de passe' onChangeText={setMdp} autoCapitalize='none' secureTextEntry={true}></TextInput>
      <Button
        onPress={() => {
          const encrypted = base64.encode(mdp);
          console.log(encrypted)
          navigation.navigate('AuthentificationScreen', { login: login, mdp: encrypted })
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