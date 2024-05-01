import { useNavigation } from '@react-navigation/native'
import React from 'react';
import { StyleSheet } from 'react-native';
import { Button, View, Text } from 'react-native'
export default function Piece(props) {
  const navigation = useNavigation()
  console.log(props)

  //verifier si cette pièce est présente ddans un etat lieu avec cet id reservation
  //j'envoie id reservation +id pièce
  //je reçois true ou false si un etat ddes lieux est nécessaire
  //je ne sais pas si c'est le ddébut ou fin, c'est l'api qui gère
  //je grise 'il ne faut pas d'etat des lieux (déjà fait)
  return (
    <View style={style.reservationContainer}>
      <Text style={style.textDescription}>{props.infos.type}</Text>
      <Text style={style.textBase}>
        {props.infos.ancienneNote}, {props.infos.ancienCommentaire}
      </Text>
      <Text style={style.textDate}>
        les photos
      </Text>
      <Button
        onPress={() => {
          console.log('MIAOU ' + props.infos.id)
          navigation.navigate('PieceDetailsScreen', { props: props })
        }}
        title="Noter"
      />
    </View>
  )
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
