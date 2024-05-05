import { useState, useEffect } from 'react'
import { Button, View, Text, StyleSheet, TextInput, ScrollView, Alert } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useRoute } from '@react-navigation/native'

export default function AuthentificationScreen() {
  const route = useRoute()
  const navigation = useNavigation()
  const login = route.params?.login
  const mdp = route.params?.mdp
  const [responseData, setResponseData] = useState({})
  const [isLoading, setLoading] = useState(true)
  const link = 'http://192.168.56.1/api/authentification.php'

  useEffect(() => {
    console.log(login)
    console.log(mdp)
    console.log('on va chercher les données sur ' + link)

    fetch(link, {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ mail: login, mdp: mdp })
    })
      .then(function (response) {
        console.log('traitement réponse')
        console.log(response)
        return response.json()
      })
      .then(
        function (Data) {
          console.log('traitement données')
          setResponseData(Data)
          setLoading(false)
        },
        function (error) {
          console.log(error)
        }
      )
  }, [])
  if (isLoading) {
    return (
      <View>
        <Text>Authentification...</Text>
      </View>
    )
  } else {
    if (responseData.hasOwnProperty("message")) {
      Alert.alert(responseData.message)
      navigation.navigate('Homepage')
    } else {
      navigation.navigate('AccueilScreen', { id: responseData.id })
    }
  }
}