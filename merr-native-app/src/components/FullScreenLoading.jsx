import { Flex } from 'native-base';
import React, { useEffect, useState } from 'react';
import LottieView from 'lottie-react-native';
import PropTypes from 'prop-types';
import medArriveHeart from '../../assets/animation/medArrive-heart.json';
import loadingVisits from '../../assets/animation/loading-visits.json';
import transition from '../../assets/animation/transition.json';

function FullScreenLoading({
  isLoading, withText, children, waitTime,
}) {
  const [loading, setLoading] = useState(true);
  const needWait = waitTime > 0;

  useEffect(() => {
    if (!isLoading) {
      if (needWait) setTimeout(() => setLoading(isLoading), waitTime);
      else setLoading(isLoading);
    }
  }, [isLoading]);

  return loading || isLoading
    ? (
      <Flex bg="white" h="full" w="full">
        <LottieView source={medArriveHeart} autoPlay />
        {withText && <LottieView source={loadingVisits} autoPlay />}
        {!isLoading && needWait && <LottieView source={transition} autoPlay /> }
      </Flex>
    )
    : children;
}

FullScreenLoading.propTypes = {
  isLoading: PropTypes.bool.isRequired,
  withText: PropTypes.bool,
  children: PropTypes.element.isRequired,
  waitTime: PropTypes.number,
};

FullScreenLoading.defaultProps = {
  withText: false,
  waitTime: 0,
};

export default FullScreenLoading;
