import React, { useCallback, useEffect } from 'react';
import PropTypes from 'proptypes';
import { Box, Text, ScrollView, Flex } from 'native-base';
import { isToday, startOfDay } from 'date-fns';

import { useQuery } from '@apollo/client';
import { useFocusEffect } from '@react-navigation/native';

import VisitCard from '../../../components/VisitCard';
import PatientModal from '../../../components/PatientModal';
import FullScreenLoading from '../../../components/FullScreenLoading';
import GET_VISITS_QUERY from '../../../graphql/queries/visits/getVisits';
import useCheckValidAuth from '../../../hooks/useCheckValidAuth';
import NoVisitsIcon from '../../../components/svg/NoVisitsIcon';

import getDateWithTimeZone from '../../../helpers/getDateWithTimeZone';

import CalendarIcon from '../../../../assets/icons/calendar.svg';

function VisitsList({ startTime, endTime }) {
  const {
    data: visitsData,
    loading,
    error,
    refetch,
    startPolling,
    stopPolling,
  } = useQuery(GET_VISITS_QUERY, {
    variables: {
      limit: 20,
      start_time: startTime,
      end_time: endTime,
    },
  });
  useCheckValidAuth(error);
  const [currentVisit, setCurrentVisit] = React.useState({});
  const [patientModalVisible, setPatientModalVisible] = React.useState(false);
  const [visitsInTerminalState, setVisitsInTerminalState] = React.useState([]);

  useFocusEffect(
    useCallback(() => {
      refetch();
    }, [currentVisit]),
  );

  useEffect(() => {
    startPolling(60000);
    return () => stopPolling();
  }, [startPolling, stopPolling]);

  const setAndOpenModal = (visit) => {
    setCurrentVisit(visit);
    setPatientModalVisible(true);
  };

  const visits = visitsData?.getVisits?.filter((v) => v?.program?.v2) || [];

  useEffect(() => {
    const terminalVisitIds = [];

    // Determine which visits are completed
    visits?.map((v) => {
      let completed;
      v.visit_events?.forEach((event) => {
        if (event.event_type === 'complete') {
          completed = true;
        }
      });
      if (v?.canceled || completed) {
        terminalVisitIds.push(v.id.toString());
      }
    });

    setVisitsInTerminalState(terminalVisitIds);
  }, [JSON.stringify(visits)]);

  // The tab view doesn't reliably pass in variables on tab switching, so this is necessary
  const isPastView =
    visits &&
    visits[0] &&
    new Date(visits[0].start_time).getTime() < startOfDay(new Date());

  const calculateIfActionsAllowed = (visit) => {
    // actions always allowed in the past
    if (isPastView) {
      return true;
    } else {
      let currentIndex;
      if (visits.length > 0) {
        currentIndex = visits?.findIndex(
          (v) => v.id.toString() === visit.id.toString(),
        );
      }
      // only get visits that take place before current visit
      const relevantVisits = visits.slice(0, currentIndex);
      // remove plus one visits associated with this visit from calculation
      if (visit?.visitGroup?.visits) {
        visit?.visitGroup?.visits.forEach((plusOneVisit) => {
          const indexOfPlusOne = relevantVisits.findIndex(
            (rv) => rv.id.toString() === plusOneVisit?.id.toString(),
          );
          if (indexOfPlusOne > -1) {
            relevantVisits.splice(indexOfPlusOne, 1);
          }
        });
      }

      let allowFurtherActions = true;
      // first visit of the day should always be actionable
      if (currentIndex === 0) {
        return true;
      } else {
        relevantVisits.forEach((v) => {
          if (
            visitsInTerminalState.includes(v.id.toString()) &&
            allowFurtherActions !== false
          ) {
            allowFurtherActions = true;
          } else {
            allowFurtherActions = false;
          }
        });
      }
      return allowFurtherActions;
    }
  };

  const displayVisits = () => {
    if (error) {
      return (
        <Box>
          <Text>Something went wrong when loading your visits?.</Text>
        </Box>
      );
    }

    if (visits?.length <= 0) {
      return (
        <Flex direction="column" alignItems="center" pt="26px">
          <NoVisitsIcon />
          <Text pt="10px">No visits scheduled</Text>
        </Flex>
      );
    }

    const datesOfVisits = () =>
      visits?.map((v) => {
        const dates = [];
        const date = getDateWithTimeZone(v.start_time, 'MMMM D');
        if (!dates?.includes(date)) {
          return date;
        }
      });

    const jsxHolder = [];
    const hasAVisitToday = datesOfVisits()?.includes(
      getDateWithTimeZone(new Date(), 'MMMM D'),
    );

    if (
      visits?.length > 0 &&
      hasAVisitToday === false &&
      isPastView === false
    ) {
      jsxHolder.push(
        <Flex direction="column" w="100%">
          <Flex direction="row" justify="space-between" mb="10px" mx="8px">
            <Text variant="subTitle">
              {'Today, '}
              {getDateWithTimeZone(new Date(), 'MMMM D')}
            </Text>
            <CalendarIcon />
          </Flex>

          <Flex direction="column" alignItems="center" pt="26px" pb="16px">
            <NoVisitsIcon />
            <Text pt="10px">No visits scheduled</Text>
          </Flex>
        </Flex>,
      );
    }

    const displayedDates = [];
    visits?.forEach((v, i) => {
      if (v?.program?.v2) {
        const date = getDateWithTimeZone(v.start_time, 'MMMM D');

        if (displayedDates?.includes(date)) {
          jsxHolder.push(
            <Box key={v.id} w="full">
              <VisitCard
                visit={v}
                setAndOpenModal={setAndOpenModal}
                actionsAllowed={() => calculateIfActionsAllowed(v)}
              />
            </Box>,
          );
        } else {
          const today = isToday(new Date(v.start_time)) && 'Today, ';
          displayedDates.push(date);

          jsxHolder.push(
            <Box key={v.start_time} w="full">
              <Flex direction="row" justify="space-between" mb="10px" mx="8px">
                <Text variant="subTitle">
                  {today && 'Today, '}
                  {date}
                </Text>
                {today && <CalendarIcon />}
              </Flex>
              <VisitCard
                visit={v}
                setAndOpenModal={setAndOpenModal}
                actionsAllowed={() => calculateIfActionsAllowed(v)}
              />
            </Box>,
          );
        }
      }
    });
    return jsxHolder;
  };

  return (
    <ScrollView contentContainerStyle={{ flexGrow: 1 }}>
      <Box
        paddingTop={5}
        flexDirection="column"
        alignItems="center"
        height="100%"
        px="8px"
      >
        {visits?.length ? (
          <PatientModal
            modalVisible={patientModalVisible}
            setModalVisible={() => setPatientModalVisible(false)}
            patient={currentVisit.patient}
            visit={currentVisit}
          />
        ) : null}
        <FullScreenLoading isLoading={loading} withText>
          <>{displayVisits()}</>
        </FullScreenLoading>
      </Box>
    </ScrollView>
  );
}

VisitsList.propTypes = {
  startTime: PropTypes.string.isRequired,
  endTime: PropTypes.string.isRequired,
};

export default VisitsList;
