import React, { useState } from 'react';
import PropTypes from 'proptypes';
import {
  Box,
  Text,
  Button,
  Flex,
  useToast,
  TextArea,
  CloseIcon,
  Pressable,
} from 'native-base';
import { useQuery, useMutation } from '@apollo/client';
import CREATE_VISIT_NOTE_MUTATION from '../../graphql/mutations/visit_note/createVisitNote';
import GET_CURRENT_USER_QUERY from '../../graphql/queries/user/currentUser';
import GET_VISIT_NOTES_QUERY from '../../graphql/queries/visit_notes/getVisitNotes';
import { sentryCaptureException } from '../../service/sentry';
import useCheckValidAuth from '../../hooks/useCheckValidAuth';

function AddVisitNote({ onClose, visit, setTriggerAlert }) {
  const [textAreaValue, setTextAreaValue] = useState('');
  const toast = useToast();
  const [createVisitNote, { error: visitError }] = useMutation(
    CREATE_VISIT_NOTE_MUTATION,
    {
      refetchQueries: [
        {
          query: GET_VISIT_NOTES_QUERY,
          variables: { notable_id: parseInt(visit.id, 10) },
        },
        'GetVisitNotes',
      ],
    },
  );

  const {
    // loading: loadingUser,
    error: errorDataUser,
    data: userData,
  } = useQuery(GET_CURRENT_USER_QUERY);

  const error = errorDataUser || visitError;
  useCheckValidAuth(error);

  const currentUserData = userData?.getCurrentUser;

  const postVisitEvent = async () => {
    if (currentUserData?.id) {
      try {
        createVisitNote({
          variables: {
            content: textAreaValue,
            current_user_id: parseInt(currentUserData?.id, 10),
            visit_id: parseInt(visit?.id, 10),
          },
        });
        setTextAreaValue('');
        setTriggerAlert(true);
        onClose();
      } catch (fetchError) {
        sentryCaptureException(fetchError, currentUserData);
      }
    } else {
      toast.show({
        description: 'Something went wrong: user was not set correctly',
      });
    }
  };

  const close = () => {
    setTextAreaValue('');
    onClose();
  };

  return (
    <Box bg="#00000066" height="100%" pt="50px">
      <Box variant="drawer" height="100%" px="16px">
        <Flex direction="row" pt="36px" justifyContent="space-between" align="center">
          <Pressable onPress={() => close()}>
            <CloseIcon size="4" color="#404040" />
          </Pressable>
          <Button
            isDisabled={!textAreaValue}
            onPress={() => postVisitEvent()}
            variant="link"
            w="12%"
            p="0"
          >
            Save
          </Button>
        </Flex>
        <Text fontWeight="700" fontSize="14px" pb="16px" pt="44px">
          Add Note
        </Text>
        <TextArea
          onChangeText={(text) => setTextAreaValue(text)}
          variant="noteCard"
          placeholder="Write a note"
          value={textAreaValue}
        />
      </Box>
    </Box>
  );
}

AddVisitNote.propTypes = {
  onClose: PropTypes.func.isRequired,
  visit: PropTypes.shape().isRequired,
  setTriggerAlert: PropTypes.func.isRequired,
};

export default AddVisitNote;
