import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text, StyleSheet, TextInput,ScrollView, Alert } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useRoute } from '@react-navigation/native'
import RNPickerSelect from 'react-native-picker-select';
import { useState, useEffect } from 'react'
import Equipement from '../components/Equipement';

import * as ImagePicker from 'expo-image-picker';

export default function PieceDetailsScreen() {
    const options = [
        { label: '1⭐', value: '1' },
        { label: '2⭐⭐', value: '2' },
        { label: '3⭐⭐⭐', value: '3' },
        { label: '4⭐⭐⭐⭐', value: '4' },
        { label: '5⭐⭐⭐⭐⭐', value: '5' },
      ];
  const navigation = useNavigation()
  const route = useRoute()
  const props = route.params?.props
  const idReservation = route.params?.idReservation
  
  const [count, setCount]= useState(0)
  const [lesImages, setLesImages] = useState([])
  const [commentaire, onChangeCommentaire] = useState('');
  const [selectedValue, setSelectedValue] = useState(5);
  const [IDEtatLieux, setIDEtatLieux] = useState(0)
  console.log("le props")
  console.log(props.equipements)
  const styles = StyleSheet.create({
    input: {
      height: 40,
      margin: 12,
      borderWidth: 1,
      padding: 10,
    },image: {
      width: 200,
      height: 200,
    },
  });


  const [image, setImage] = useState(null);
  const pickImage = async () => {
    // No permissions request is necessary for launching the image library
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    if (!result.canceled) {
      lesImages.push(result.assets[0].uri)
      setCount( lesImages.length)
    }
  };
  
  return (
    <ScrollView >
      <Text style={{alignItems: 'center' }}>PieceDetailsScreen pour la pièce : {props.infos.id}</Text>
      <Text> Ancien commentaire : {props.infos.hasOwnProperty("ancienCommentaire") ? props.infos.ancienCommentaire : "Soyez le premier à commenter !" }</Text>
      <Text> Ancienne note : {props.infos.hasOwnProperty("ancienneNote")  ? props.infos.ancienneNote : "Soyez le premier à noter !" }</Text>
      <TextInput
       style={styles.input}

        onChangeText={onChangeCommentaire}
        value={commentaire}
        placeholder="Votre beau commentaire"
      />
      <RNPickerSelect
        items={options}
        onValueChange={(value) => setSelectedValue(value)}
        value={selectedValue}
      />
      
      <Button title="Choisissez dans votre galerie" onPress={pickImage} />
      {<Text>Vous avez séléctionné {count} image </Text> }

      <Button
        onPress={() => {
          if(commentaire!='' && count!=0 && selectedValue!=null){
            //on balance la sauce
            fetch('http://192.168.1.30/api/etatLieux.php', {
              method: 'POST',
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({idReservation: idReservation, idPiece: props.infos.id, note: selectedValue, commentaire: commentaire})
            }).then(function (response) {
              // console.log('traitement réponse')
              // console.log(response)
              return response.json()
            }).then(
              function (Data) {
                console.log('traitement données etat lieux')
                setIDEtatLieux(Data.ID)
                console.log(Data.ID)
                console.log("-------------------------------------------------------")
                console.log(JSON.stringify({idReservation: idReservation, idPiece: props.infos.id, note: selectedValue, commentaire: commentaire}))
              console.log("IDETATLieux : " + IDEtatLieux)
              //on envoie les photos
              ended = lesImages.length
              
              for (let uneimg of lesImages){
                console.log(uneimg)
                
                let body = new FormData();
                body.append('photo', {uri: uneimg,name: IDEtatLieux+'.'+props.infos.id+'.jpeg',type: 'image/jpeg'});
                // body.append(JSON.stringify({idEtatLieux: IDEtatLieux, idPiece: props.infos.id, extension: ".jpeg"}))
                console.log("_-_-_-_-_-_-_-_-_-_-_-_--_")
                fetch("http://192.168.56.1/api/photo.php",{ method: 'POST',headers:{  
                    "Content-Type": "multipart/form-data",
                    } , body :body} ).then(function (response) {
                      console.log('traitement réponse de lupload dimage')
                      console.log(response)
                      return response.text()
                    }).then(
                      function (Data) {
                        console.log('traitement données de lupload dimage')
                        console.log(Data)                        
                      },
                      function (error) {
                        console.log(error)
                      }
                    )
                    ended = ended-1
              }
              
        
              
              if(ended==0){
                console.log("on y va")
                navigation.navigate('AccueilScreen')
              }
                
              },
              function (error) {
                console.log(error)
                Alert.alert('Oopsie', "Une erreur est survenue :/")
              }
            )
            
            
            
          } else {
            //toast
            Alert.alert('🛑Attention🛑', 'Merci de remplir correctement chaque champ et de prendre des photos avant de valider !')
          }
          
        }}
        title="Valider"
      />
      <Text>Les équipements de la pièce :</Text>
       { typeof props.equipements !=  'undefined' ?
      props.equipements.map((unEquipement, index) => (
        <Equipement
          key={index}
          infos={unEquipement}
        />
      )) : null}
    </ScrollView>
  )

 
}