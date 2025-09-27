import React, { useState } from 'react';
import { Keyboard, TouchableWithoutFeedback } from 'react-native';
import PropTypes from 'proptypes';
import {
  Box, Text, Flex, ScrollView, Alert,
} from 'native-base';
import { useQuery } from '@apollo/client';
import AddVisitNote from './addVisitNotes';
import GET_VISIT_NOTES_QUERY from '../../graphql/queries/visit_notes/getVisitNotes';

import CustomBackButton from '../../components/CustomBackButton';

import getDateWithTimeZone from '../../helpers/getDateWithTimeZone';
import useCheckValidAuth from '../../hooks/useCheckValidAuth';

import NotFound from '../../../assets/icons/fi_times-alt.svg';

function Notes({ route }) {
  const [isAddVisitModalOpen, setIsAddVisitModalOpen] = useState(false);
  const [triggerAlert, setTriggerAlert] = useState(false);
  const { id } = route?.params?.visit || {};

  const {
    // loading: loadingVisitNotes,
    error: errorVisitNotes,
    data: visitNotesData,
  } = useQuery(
    GET_VISIT_NOTES_QUERY,
    {
      variables: { notable_id: parseInt(id, 10) },
    },
    [isAddVisitModalOpen],
  );

  useCheckValidAuth(errorVisitNotes);

  const closeNoteModal = () => {
    setIsAddVisitModalOpen(false);
  };

  const openNoteModal = () => {
    setIsAddVisitModalOpen(true);
    setTriggerAlert(false);
  };

  return (
    <TouchableWithoutFeedback onPress={() => Keyboard.dismiss()}>
      <Box bg="white" h="100%">
        {isAddVisitModalOpen && (
          <AddVisitNote
            onClose={() => closeNoteModal()}
            visit={route?.params?.visit}
            setTriggerAlert={setTriggerAlert}
          />
        )}
        <ScrollView mx="16px" mt="50px">
          {triggerAlert && (
            <Alert status="info" mb="16px">
              <Flex direction="row" alignItems="center">
                <Alert.Icon mr="4px" />
                <Text>Note added successfully!</Text>
              </Flex>
            </Alert>
          )}
          <Flex direction="row" justify="space-between" mb="16px">
            <CustomBackButton />
            <Text variant="title" fontSize="text">Notes</Text>
            <Text variant="button" onPress={() => openNoteModal()}>
              Add New
            </Text>
          </Flex>
          <Flex pb="8px" direction="row" justifyContent="flex-end" />
          {visitNotesData?.getVisitNotes?.length <= 0 || !visitNotesData ? (
            <Flex align="center" mt="59px">
              <NotFound />
              <Text mt="9px" variant="text">There are no notes added</Text>
            </Flex>
          ) : (
            visitNotesData?.getVisitNotes?.map((note) => (
              <Box key={note.id} pb="24px">
                <Box variant="noteCard" colorScheme="warmGray">
                  <Text color="#404040">{note.content}</Text>
                </Box>
                <Flex direction="row" justifyContent="space-between">
                  <Text color="#737373">{note?.creator?.display_name}</Text>
                  <Flex>
                    <Text color="#737373">
                      {getDateWithTimeZone(note?.created_at, 'dd MMM yyyy, h:mm a')}
                    </Text>
                  </Flex>
                </Flex>
              </Box>
            ))
          )}
        </ScrollView>
      </Box>
    </TouchableWithoutFeedback>
  );
}

Notes.propTypes = {
  route: PropTypes.object.isRequired,
};

export default Notes;
