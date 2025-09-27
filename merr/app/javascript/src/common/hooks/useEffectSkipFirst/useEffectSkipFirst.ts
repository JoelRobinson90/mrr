import { DependencyList, EffectCallback, useEffect, useRef } from 'react';

export const useEffectSkipFirst = (effect: EffectCallback, deps?: DependencyList) => {
  const hasRun = useRef(false);

  return useEffect(() => {
    if (!hasRun.current) {
      hasRun.current = true;
      return;
    }
    effect();
  }, deps);
};
