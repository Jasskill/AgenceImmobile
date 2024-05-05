import { useNavigation } from '@react-navigation/native'
import React from 'react';
import { StyleSheet } from 'react-native';
import { Button, View, Text } from 'react-native'
import { useState, useEffect } from 'react'
export default function Piece(props) {
  const navigation = useNavigation()
  console.log(props)

  //verifier si cette pièce est présente ddans un etat lieu avec cet id reservation
  //j'envoie id reservation +id pièce
  //je reçois true ou false si un etat ddes lieux est nécessaire
  //je ne sais pas si c'est le ddébut ou fin, c'est l'api qui gère
  //je grise 'il ne faut pas d'etat des lieux (déjà fait)

  var link = 'http://192.168.1.30/api/etatLieux.php?idReservation='
  const [verifData, setVerifData] = useState({})
  const [isLoading, setLoading] = useState(true)

  useEffect(() => {
    link += props.idReservation + "&idPiece=" + props.infos.id
    console.log('on va chercher les données sur ' + link)
    fetch(link)
      .then(function (response) {
        console.log('traitement réponse dans la pièce')
        console.log(response)
        return response.json()
      })
      .then(
        function (data) {
          console.log('traitement données dans la pièce')
          setVerifData(data)
          setLoading(false)
          console.log("MLENTOS")
          console.log(verifData)
        },
        function (error) {
          console.log(error)
        }
      )
  }, [])

  if(isLoading){
    return(<View><Text>Loading 😊</Text></View>)
  } else {
  return (
    <View style={style.reservationContainer}>
      <Text style={style.textDescription}>{props.infos.type}</Text>
      <Text style={style.textBase}>
        {props.infos.ancienneNote}, {props.infos.ancienCommentaire}
      </Text>
      <Text style={style.textDate}>
        les photos
      </Text>
      { verifData.etatLieuxNecessaire ? <Button
        onPress={() => {
          navigation.navigate('PieceDetailsScreen', { props: props, idReservation: props.idReservation })
        }}
        title="Noter"
      /> :null}
      
    </View>
  )
}
}
const style = StyleSheet.create({
  reservationContainer: {
    backgroundColor: '#555',
    margin: 20,
  },
  textDescription: { fontSize: 20, fontWeight: 'bold', textAlign: 'center' },
  textDate: { fontStyle: 'italic', textAlign: 'center' },
  textBase: { textAlign: 'center' },
})
