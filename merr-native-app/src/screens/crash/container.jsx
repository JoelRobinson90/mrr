import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AuthContext } from '../../context/auth';
import CrashScreen from './crash';
import { sentryCaptureException } from '../../service/sentry';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = {
      error: null,
    };
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    const { onError } = this.props;
    if (typeof onError === 'function') {
      onError(error, info.componentStack);
    }
  }

  resetError = () => {
    this.setState({ error: null });
  };

  render() {
    const { children } = this.props;
    const { error } = this.state;

    return error ? (
      <AuthContext.Consumer>
        {([currentUser]) => {
          sentryCaptureException(error, currentUser);
          return (
            <CrashScreen
              goBack={this.resetError}
            />
          );
        }}
      </AuthContext.Consumer>
    )
      : children;
  }
}

ErrorBoundary.propTypes = {
  children: PropTypes.node.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  onError: PropTypes.any,
};

ErrorBoundary.defaultProps = {
  onError: null,
};

export default ErrorBoundary;
