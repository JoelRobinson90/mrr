import { EuiHorizontalRule, EuiSpacer, EuiText, EuiTextAlign, EuiTextColor } from '@elastic/eui';
import { Meta } from '@storybook/react';
import React from 'react';

export default {
  title: 'Display/Typography',
  component: EuiText,
  argTypes: {},
} as Meta;

export const TextExamples = () => (
  <div>
    <EuiText grow={false}>
      <h1>This is Heading One</h1>
      <p>
        Here are some examples of typography features provided by EUI. Try changing the &#39;size&#39; control to see
        different size options for body text.
      </p>

      <p>
        Far out in the uncharted backwaters of the <a href="#">unfashionable</a> end of the western spiral arm of the
        Galaxy lies a small unregarded yellow sun. When suddenly some wild JavaScript code appeared!{' '}
        <code>const whoa = &quot;!&quot;</code>
      </p>

      <pre>
        <code>const completelyUnexpected = &quot;the audacity!&quot;;</code>
      </pre>

      <p>That was close.</p>

      <blockquote>
        <p>
          I&apos;ve seen things you people wouldn&apos;t believe. Attack ships on fire off the shoulder of Orion. I
          watched C-beams glitter in the dark near the Tannhäuser Gate. All those moments will be lost in time, like
          tears in rain. Time to die.
        </p>
      </blockquote>

      <p>
        Orbiting this at a distance of roughly ninety-two million miles is an utterly insignificant little blue green
        planet whose ape- descended life forms are so amazingly primitive that they still think digital watches are a
        pretty neat idea.
      </p>

      <ul>
        <li>List item one</li>
        <li>List item two</li>
        <li>Dolphins</li>
      </ul>

      <p>
        This planet has - or rather had - a problem, which was this: most of the people living on it were unhappy for
        pretty much of the time. Many solutions were suggested for this problem, but most of these were largely
        concerned with the movements of small green pieces of paper, which is odd because on the whole it was not the
        small green pieces of paper that were unhappy.
      </p>

      <h2>This is Heading Two</h2>

      <ol>
        <li>Number one</li>
        <li>Number two</li>
        <li>Dolphins again</li>
      </ol>

      <p>
        But the dog wasn&rsquo;t lazy, it was just practicing mindfulness, so it had a greater sense of
        life-satisfaction than that fox with all its silly jumping.
      </p>

      <p>
        And from the fox&rsquo;s perspective, life was full of hoops to jump <em>through</em>, low-hanging fruit to jump
        <em>for</em>, and dead car batteries to jump-<em>start</em>.
      </p>

      <h3>This is Heading Three</h3>

      <p>
        So it thought the dog was making a poor life choice by focusing so much on mindfulness. What if its car broke
        down?
      </p>

      <h4>This is Heading Four</h4>

      <p>
        So it thought the dog was making a poor life choice by focusing so much on mindfulness. What if its car broke
        down?
      </p>

      <h5>This is Heading Five</h5>

      <p>
        <small>
          So it thought the dog was making a poor life choice by focusing so much on mindfulness. What if its car broke
          down?
        </small>
      </p>

      <h6>This is Heading Six</h6>

      <EuiHorizontalRule />

      <dl>
        <dt>The Elder Scrolls: Morrowind</dt>
        <dd>The opening music alone evokes such strong memories.</dd>
        <dt>TIE Fighter</dt>
        <dd>The sequel to XWING, join the dark side and fly for the Emporer.</dd>
        <dt>Quake 2</dt>
        <dd>The game that made me drop out of college.</dd>
      </dl>

      <EuiHorizontalRule />

      <dl className="eui-definitionListReverse">
        <dt>Name</dt>
        <dd>The Elder Scrolls: Morrowind</dd>
        <dt>Game style</dt>
        <dd>Open-world, fantasy, action role-playing</dd>
        <dt>Release date</dt>
        <dd>2002</dd>
      </dl>
    </EuiText>
  </div>
);

export const TextSizes = () => (
  <>
    <EuiText size="m">
      <p>
        This is Medium text, size=&quot;m&quot;, which is the default. Hello there! Come here my little friend.
        Don&#39;t be afraid. Don&#39;t worry, he&#39;ll be all right. What happened? Rest easy, son, you&#39;ve had a
        busy day. You&#39;re fortunate you&#39;re still in one piece. Ben? Ben Kenobi! Boy, am I glad to see you! The
        Jundland wastes are not to be traveled lightly. Tell me young Luke, what brings you out this far? Oh, this
        little droid! I think he&#39;s searching for his former master...I&#39;ve never seen such devotion in a droid
        before...there seems to be no stopping him. He claims to be the property of an Obi-Wan Kenobi. Is he a relative
        of yours? Do you know who he&#39;s talking about?
      </p>
    </EuiText>

    <EuiSpacer />

    <EuiText size="s">
      <p>
        This is Small text, size=&quot;s&quot;. Did you hear that? They&#39;ve shut down the main reactor. We&#39;ll be
        destroyed for sure. This is madness! We&#39;re doomed! There&#39;ll be no escape for the Princess this time.
        What&#39;s that? Artoo! Artoo-Detoo, where are you? At last! Where have you been? They&#39;re heading in this
        direction. What are we going to do? We&#39;ll be sent to the spice mine of Kessel or smashed into who knows
        what! Wait a minute, where are you going?
      </p>
    </EuiText>

    <EuiSpacer />

    <EuiText size="xs">
      <p>
        This is X-Small text, size=&quot;xs&quot;. To your stations! Come with me. Close all outboard shields! Close all
        outboard shields! Yes. We&#39;ve captured a freighter entering the remains of the Alderaan system. It&#39;s
        markings match those of a ship that blasted its way out of Mos Eisley. They must be trying to return the stolen
        plans to the princess. She may yet be of some use to us. Unlock one-five-seven and nine. Release charges.
        There&#39;s no one on board, sir. According to the log, the crew abandoned ship right after takeoff. It must be
        a decoy, sir. Several of the escape pods have been jettisoned.
      </p>
    </EuiText>
  </>
);

export const Colors = () => (
  <>
    <EuiText>
      <p>
        <EuiTextColor color="default">Default text color</EuiTextColor>
      </p>
      <p>
        <EuiTextColor color="subdued">Subdued text color</EuiTextColor>
      </p>
      <p>
        <EuiTextColor color="secondary">Secondary text color</EuiTextColor>
      </p>
      <p>
        <EuiTextColor color="accent">Accent text color</EuiTextColor>
      </p>
      <p>
        <EuiTextColor color="warning">Warning text color</EuiTextColor>
      </p>
      <p>
        <EuiTextColor color="danger">Danger text color</EuiTextColor>
      </p>
      <p>
        <span style={{ background: '#222' }}>
          <EuiTextColor color="ghost">Ghost text color is always white regardless of theme.</EuiTextColor>
        </span>
      </p>
    </EuiText>

    <EuiSpacer />

    <EuiText color="danger">
      <h2>Works on EuiText as well.</h2>
      <p>
        Sometimes you need to color entire blocks of text, no matter what is in them. You can always apply color
        directly (versus using the separated component) to make it easy. Links should still{' '}
        <a href="#">properly color</a>.
      </p>
    </EuiText>
  </>
);

export const Alignment = () => (
  <div>
    <EuiText>
      <EuiTextAlign textAlign="left">
        <p>Left aligned paragraph.</p>
      </EuiTextAlign>
      <EuiTextAlign textAlign="center">
        <p>Center aligned paragraph.</p>
      </EuiTextAlign>
      <EuiTextAlign textAlign="right">
        <p>Right aligned paragraph.</p>
      </EuiTextAlign>
    </EuiText>
    <EuiSpacer />
    <EuiText textAlign="center">
      <p>
        You can also pass alignment to <strong>EuiText</strong> directly with a prop
      </p>
    </EuiText>
    <EuiText textAlign="center" color="secondary">
      <p>And in conjunction with coloring.</p>
    </EuiText>
  </div>
);
