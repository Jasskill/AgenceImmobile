import { useNavigation } from '@react-navigation/native'
import React from 'react';
import { StyleSheet } from 'react-native';
import { Button, View,Image,  Text } from 'react-native'
export default function Photo(props) {
    console.log( "CANARD" + props)
    const styles = StyleSheet.create({
        
        tinyLogo: {
          width: 150,
          height: 150,
        },
      });
    return (<View>
        <Image 
        style={styles.tinyLogo}
         source={{uri: props.lien,}} />
    </View>)
}