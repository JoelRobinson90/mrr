import React, { useMemo, useState } from 'react';
import { Story, Meta } from '@storybook/react/types-6-0';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiButtonEmptyColor,
  EuiButtonGroup,
  EuiButtonIcon,
  EuiButtonIconColor,
  EuiFlexGroup,
  EuiFlexItem,
  EuiPanel,
  EuiSpacer,
  EuiText,
  EuiTitle,
} from '@elastic/eui';
import { htmlIdGenerator } from '@elastic/eui/lib/services';

export default {
  title: 'Components/EuiButton',
  component: EuiButton,
} as Meta;

export const Buttons: Story = () => (
  <div>
    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton onClick={() => void 0}>Primary</EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton color="secondary" onClick={() => void 0}>
          Secondary
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="secondary" fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="secondary" size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="secondary" size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton color="warning" onClick={() => void 0}>
          Warning
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="warning" fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="warning" size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="warning" size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton color="danger" onClick={() => void 0}>
          Danger
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="danger" fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="danger" size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="danger" size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton color="text" onClick={() => void 0}>
          Text
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="text" fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="text" size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton color="text" size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton isDisabled onClick={() => void 0}>
          Disabled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton isDisabled fill onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton isDisabled size="s" onClick={() => void 0}>
          Small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton isDisabled size="s" fill onClick={() => void 0}>
          Small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

export const ButtonsWithHref: Story = () => (
  <div>
    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton href="http://www.medarrive.com">Link to medarrive.com</EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButtonEmpty href="http://www.medarrive.com">Link to medarrive.com</EuiButtonEmpty>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButtonIcon href="http://www.medarrive.com" iconType="link" aria-label="This is a link" />
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton href="http://www.medarrive.com" isDisabled>
          Disabled link
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButtonEmpty href="http://www.medarrive.com" isDisabled>
          Disabled empty link
        </EuiButtonEmpty>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButtonIcon href="http://www.medarrive.com" iconType="link" aria-label="This is a link" isDisabled />
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

export const ButtonsWithIcons: Story = () => (
  <div>
    <EuiText>
      <h1>Buttons with icons</h1>
    </EuiText>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton onClick={() => void 0} iconType="arrowUp">
          Primary
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton fill iconType="arrowDown" onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconType="arrowLeft" size="s" onClick={() => void 0}>
          small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconType="arrowRight" size="s" fill onClick={() => void 0}>
          small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" onClick={() => void 0} iconType="arrowUp">
          Primary
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" fill iconType="arrowDown" onClick={() => void 0}>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" iconType="arrowLeft" size="s" onClick={() => void 0}>
          small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" iconType="arrowRight" size="s" fill onClick={() => void 0}>
          small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>

    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" onClick={() => void 0} iconType="arrowUp" isDisabled>
          Disabled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" fill iconType="arrowDown" onClick={() => void 0} isDisabled>
          Filled
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" iconType="arrowLeft" size="s" onClick={() => void 0} isDisabled>
          small
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton iconSide="right" iconType="arrowRight" size="s" fill onClick={() => void 0} isDisabled>
          small and filled
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

export const LoadingState: Story = () => (
  <div>
    <EuiFlexGroup gutterSize="s" alignItems="center" wrap>
      <EuiFlexItem grow={false}>
        <EuiButton isLoading={true}>Loading&hellip;</EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton fill isLoading={true}>
          Loading&hellip;
        </EuiButton>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiButton fill isLoading={true} iconType="check" iconSide="right">
          Loading&hellip;
        </EuiButton>
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

export const EmptyButtons: Story = () => {
  const colors: (EuiButtonEmptyColor | 'disabled')[] = ['primary', 'success', 'warning', 'danger', 'text', 'disabled'];

  return (
    <div>
      {colors.map((value) => (
        <>
          <EuiFlexGroup gutterSize="s" key={value} alignItems="center">
            <EuiFlexItem grow={false}>
              <EuiButtonEmpty
                style={{
                  textTransform: 'capitalize',
                }}
                isDisabled={value === 'disabled' ? true : false}
                color={value !== 'disabled' ? value : 'primary'}
                onClick={() => void 0}
              >
                {value}
              </EuiButtonEmpty>
            </EuiFlexItem>

            <EuiFlexItem grow={false}>
              <EuiButtonEmpty
                isDisabled={value === 'disabled' ? true : false}
                color={value !== 'disabled' ? value : 'primary'}
                size="s"
                onClick={() => void 0}
              >
                small
              </EuiButtonEmpty>
            </EuiFlexItem>

            <EuiFlexItem grow={false}>
              <EuiButtonEmpty
                isDisabled={value === 'disabled' ? true : false}
                color={value !== 'disabled' ? value : 'primary'}
                size="xs"
                onClick={() => void 0}
              >
                extra small
              </EuiButtonEmpty>
            </EuiFlexItem>
          </EuiFlexGroup>
        </>
      ))}

      <EuiFlexGroup gutterSize="s" alignItems="center">
        <EuiFlexItem grow={false}>
          <EuiButtonEmpty onClick={() => void 0} iconType="arrowDown">
            Icon left
          </EuiButtonEmpty>
        </EuiFlexItem>

        <EuiFlexItem grow={false}>
          <EuiButtonEmpty onClick={() => void 0} iconType="arrowDown" iconSide="right">
            Icon right
          </EuiButtonEmpty>
        </EuiFlexItem>
      </EuiFlexGroup>

      <EuiFlexGroup gutterSize="s" alignItems="center">
        <EuiFlexItem grow={false}>
          <EuiButtonEmpty onClick={() => void 0} isLoading>
            Loading
          </EuiButtonEmpty>
        </EuiFlexItem>

        <EuiFlexItem grow={false}>
          <EuiButtonEmpty onClick={() => void 0} isLoading iconSide="right">
            Loading
          </EuiButtonEmpty>
        </EuiFlexItem>
      </EuiFlexGroup>
    </div>
  );
};

export const FlushEmptyButton: Story = () => (
  <EuiFlexGroup gutterSize="s" alignItems="center">
    <EuiFlexItem grow={false}>
      <EuiButtonEmpty flush="left">Flush left</EuiButtonEmpty>
    </EuiFlexItem>

    <EuiFlexItem grow={false}>
      <EuiButtonEmpty flush="right">Flush right</EuiButtonEmpty>
    </EuiFlexItem>

    <EuiFlexItem grow={false}>
      <EuiButtonEmpty flush="both">Flush both</EuiButtonEmpty>
    </EuiFlexItem>
  </EuiFlexGroup>
);

export const ButtonIcon: Story = () => {
  const colors: EuiButtonIconColor[] = ['primary', 'text', 'accent', 'subdued', 'success', 'warning', 'danger'];

  return (
    <EuiFlexGroup gutterSize="s" alignItems="center">
      {colors.map((color) => (
        <EuiFlexItem key={color} grow={false}>
          <EuiButtonIcon color={color} onClick={() => void 0} iconType="arrowRight" aria-label="Next" />
        </EuiFlexItem>
      ))}
      <EuiFlexItem grow={false}>
        <EuiButtonIcon
          onClick={() => window.alert('Button clicked')}
          iconType="arrowRight"
          aria-label="Next"
          disabled
        />
      </EuiFlexItem>
    </EuiFlexGroup>
  );
};

export const ToggleButtons: Story = () => {
  const [toggle0On, setToggle0On] = useState(false);
  const [toggle1On, setToggle1On] = useState(true);
  const [toggle2On, setToggle2On] = useState(true);
  const [toggle3On, setToggle3On] = useState(false);

  return (
    <>
      <EuiTitle size="xxs">
        <h3>Changing content</h3>
      </EuiTitle>
      <EuiSpacer size="s" />
      <EuiButton
        onClick={() => {
          setToggle0On((isOn) => !isOn);
        }}
      >
        {toggle0On ? 'Hey there good lookin' : 'Toggle me'}
      </EuiButton>
      &emsp;
      <EuiButtonIcon
        title={toggle1On ? 'Play' : 'Pause'}
        aria-label={toggle1On ? 'Play' : 'Pause'}
        iconType={toggle1On ? 'play' : 'pause'}
        onClick={() => {
          setToggle1On((isOn) => !isOn);
        }}
      />
      <EuiSpacer size="m" />
      <EuiTitle size="xxs">
        <h3>Changing visual appearance</h3>
      </EuiTitle>
      <EuiSpacer size="s" />
      <EuiButton
        isSelected={toggle2On}
        fill={toggle2On}
        iconType={toggle2On ? 'starFilledSpace' : 'starPlusEmpty'}
        onClick={() => {
          setToggle2On((isOn) => !isOn);
        }}
      >
        Toggle me
      </EuiButton>
      &emsp;
      <EuiButtonIcon
        aria-label="Autosave"
        title="Autosave"
        iconType="save"
        aria-pressed={toggle3On}
        color={toggle3On ? 'primary' : 'subdued'}
        onClick={() => {
          setToggle3On((isOn) => !isOn);
        }}
      />
    </>
  );
};

export const ButtonGroups: Story = () => {
  const idPrefix = useMemo(() => {
    htmlIdGenerator()();
  }, []);
  const idPrefix2 = useMemo(() => {
    htmlIdGenerator()();
  }, []);
  const idPrefix3 = useMemo(() => {
    htmlIdGenerator()();
  }, []);

  const toggleButtons = [
    {
      id: `${idPrefix}0`,
      label: 'Option one',
    },
    {
      id: `${idPrefix}1`,
      label: 'Option two is selected by default',
    },
    {
      id: `${idPrefix}2`,
      label: 'Option three',
    },
  ];

  const toggleButtonsDisabled = [
    {
      id: `${idPrefix}3`,
      label: 'Option one',
    },
    {
      id: `${idPrefix}4`,
      label: 'Option two is selected by default',
    },
    {
      id: `${idPrefix}5`,
      label: 'Option three',
    },
  ];

  const toggleButtonsMulti = [
    {
      id: `${idPrefix2}0`,
      label: 'Option 1',
    },
    {
      id: `${idPrefix2}1`,
      label: 'Option 2 is selected by default',
    },
    {
      id: `${idPrefix2}2`,
      label: 'Option 3',
    },
  ];

  const toggleButtonsCompressed = [
    {
      id: `${idPrefix2}3`,
      label: 'fine',
    },
    {
      id: `${idPrefix2}4`,
      label: 'rough',
    },
    {
      id: `${idPrefix2}5`,
      label: 'coarse',
    },
  ];

  const toggleButtonsIcons = [
    {
      id: `${idPrefix3}0`,
      label: 'Align left',
      iconType: 'editorAlignLeft',
    },
    {
      id: `${idPrefix3}1`,
      label: 'Align center',
      iconType: 'editorAlignCenter',
    },
    {
      id: `${idPrefix3}2`,
      label: 'Align right',
      iconType: 'editorAlignRight',
      isDisabled: true,
    },
  ];

  const toggleButtonsIconsMulti = [
    {
      id: `${idPrefix3}3`,
      label: 'Bold',
      name: 'bold',
      iconType: 'editorBold',
    },
    {
      id: `${idPrefix3}4`,
      label: 'Italic',
      name: 'italic',
      iconType: 'editorItalic',
      isDisabled: true,
    },
    {
      id: `${idPrefix3}5`,
      label: 'Underline',
      name: 'underline',
      iconType: 'editorUnderline',
    },
    {
      id: `${idPrefix3}6`,
      label: 'Strikethrough',
      name: 'strikethrough',
      iconType: 'editorStrike',
    },
  ];

  const [toggleIdSelected, setToggleIdSelected] = useState(`${idPrefix}1`);
  const [toggleIdDisabled, setToggleIdDisabled] = useState(`${idPrefix}4`);
  const [toggleIdToSelectedMap, setToggleIdToSelectedMap] = useState({
    [`${idPrefix2}1`]: true,
  });
  const [toggleIconIdSelected, setToggleIconIdSelected] = useState(`${idPrefix3}1`);
  const [toggleIconIdToSelectedMap, setToggleIconIdToSelectedMap] = useState({});
  const [toggleIconIdToSelectedMapIcon, setToggleIconIdToSelectedMapIcon] = useState({});
  const [toggleCompressedIdSelected, setToggleCompressedIdSelected] = useState(`${idPrefix2}4`);

  const onChange = (optionId) => {
    setToggleIdSelected(optionId);
  };

  const onChangeDisabled = (optionId) => {
    setToggleIdDisabled(optionId);
  };

  const onChangeMulti = (optionId) => {
    const newToggleIdToSelectedMap = {
      ...toggleIdToSelectedMap,
      ...{
        [optionId]: !toggleIdToSelectedMap[optionId],
      },
    };
    setToggleIdToSelectedMap(newToggleIdToSelectedMap);
  };

  const onChangeIcons = (optionId) => {
    setToggleIconIdSelected(optionId);
  };

  const onChangeCompressed = (optionId) => {
    setToggleCompressedIdSelected(optionId);
  };

  const onChangeIconsMulti = (optionId) => {
    const newToggleIconIdToSelectedMap = {
      ...toggleIconIdToSelectedMap,
      ...{
        [optionId]: !toggleIconIdToSelectedMap[optionId],
      },
    };

    setToggleIconIdToSelectedMap(newToggleIconIdToSelectedMap);
  };

  const onChangeIconsMultiIcons = (optionId) => {
    const newToggleIconIdToSelectedMapIcon = {
      ...toggleIconIdToSelectedMapIcon,
      ...{
        [optionId]: !toggleIconIdToSelectedMapIcon[optionId],
      },
    };

    setToggleIconIdToSelectedMapIcon(newToggleIconIdToSelectedMapIcon);
  };

  return (
    <>
      <EuiButtonGroup
        legend="This is a basic group"
        options={toggleButtons}
        idSelected={toggleIdSelected}
        onChange={(id) => onChange(id)}
      />
      <EuiSpacer size="m" />
      <EuiTitle size="xxs">
        <h3>Primary &amp; multi select</h3>
      </EuiTitle>
      <EuiSpacer size="s" />
      <EuiButtonGroup
        legend="This is a primary group"
        options={toggleButtonsMulti}
        idToSelectedMap={toggleIdToSelectedMap}
        onChange={(id) => onChangeMulti(id)}
        color="primary"
        type="multi"
      />
      <EuiSpacer size="m" />
      <EuiTitle size="xxs">
        <h3>Disabled &amp; full width</h3>
      </EuiTitle>
      <EuiSpacer size="s" />
      <EuiButtonGroup
        legend="This is a disabled group"
        options={toggleButtonsDisabled}
        idSelected={toggleIdDisabled}
        onChange={(id) => onChangeDisabled(id)}
        buttonSize="m"
        isDisabled
        isFullWidth
      />
      <EuiSpacer size="m" />
      <EuiTitle size="xxs">
        <h3>Icons only</h3>
      </EuiTitle>
      <EuiSpacer size="s" />
      <EuiButtonGroup
        legend="Text align"
        options={toggleButtonsIcons}
        idSelected={toggleIconIdSelected}
        onChange={(id) => onChangeIcons(id)}
        isIconOnly
      />
      &nbsp;&nbsp;
      <EuiButtonGroup
        legend="Text style"
        options={toggleButtonsIconsMulti}
        idToSelectedMap={toggleIconIdToSelectedMap}
        onChange={(id) => onChangeIconsMulti(id)}
        type="multi"
        isIconOnly
      />
      <EuiSpacer />
      <EuiPanel style={{ maxWidth: 300 }}>
        <EuiTitle size="xxxs">
          <h3>Compressed groups should always be fullWidth so they line up nicely in their small container.</h3>
        </EuiTitle>
        <EuiSpacer size="s" />
        <EuiButtonGroup
          name="coarsness"
          legend="This is a basic group"
          options={toggleButtonsCompressed}
          idSelected={toggleCompressedIdSelected}
          onChange={(id) => onChangeCompressed(id)}
          buttonSize="compressed"
          isFullWidth
        />
        <EuiSpacer />
        <EuiTitle size="xxxs">
          <h3>Unless they are icon only</h3>
        </EuiTitle>
        <EuiSpacer size="s" />
        <EuiButtonGroup
          legend="Text style"
          className="eui-displayInlineBlock"
          options={toggleButtonsIconsMulti}
          idToSelectedMap={toggleIconIdToSelectedMapIcon}
          onChange={(id) => onChangeIconsMultiIcons(id)}
          type="multi"
          buttonSize="compressed"
          isIconOnly
        />
      </EuiPanel>
    </>
  );
};
