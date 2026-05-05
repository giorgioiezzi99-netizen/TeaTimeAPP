import "./index.css";
import { Composition } from "remotion";
import {
  TeaTimerAd15,
  TeaTimerAd30,
  TeaTimerBumper6,
  TeaTimerThumbnailHero,
  TeaTimerThumbnailScanner,
} from "./compositions/TeaTimerCampaign";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="TeaTimerAd15"
        component={TeaTimerAd15}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="TeaTimerAd30"
        component={TeaTimerAd30}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="TeaTimerBumper6"
        component={TeaTimerBumper6}
        durationInFrames={180}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="TeaTimerThumbnailHero"
        component={TeaTimerThumbnailHero}
        durationInFrames={1}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="TeaTimerThumbnailScanner"
        component={TeaTimerThumbnailScanner}
        durationInFrames={1}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
