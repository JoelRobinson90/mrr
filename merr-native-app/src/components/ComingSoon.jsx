import React from 'react';
import { Flex, Text } from 'native-base';

function ComingSoon() {
  return (
    <Flex align="center" mt="80px">
      <Text variant="title" color="muted.600" fontSize="main">
        Coming Soon
      </Text>
      <Text variant="note" fontSize="main" w="232px" mt="16px" textAlign="center">
        We are working to launch this feature very soon. Stay tuned.
      </Text>
    </Flex>
  );
}

export default ComingSoon;
