import { useNavigation } from '@react-navigation/native'
export default function Piece(props) {
  const navigation = useNavigation()
  console.log(props)
  return (
    <View style={style.reservationContainer}>
      <Text style={style.textDescription}>{props.logement.description}</Text>
      <Text style={style.textBase}>
        {props.logement.rue}, {props.logement.codePostal}
      </Text>
      <Text style={style.textDate}>
        Du {props.datedeb} au {props.datefin}
      </Text>
      <Button
        onPress={() => {
          console.log('MIAOU ' + props.idReservation)
          // navigation.navigate('AccueilScreen', { id: 6 })
        }}
        title="Voir"
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
