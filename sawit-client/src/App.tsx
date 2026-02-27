import {useState, useEffect} from "react";
import sawit_happy from "@/assets/sawit/sawit-happy.png";
import sawit_sleepy from "@/assets/sawit/sawit-sleepy.png";
import sawit_hungry from "@/assets/sawit/sawit-hungry.png";
import sawit_angry from "@/assets/sawit/sawit-angry.png";

const images = [sawit_happy, sawit_sleepy, sawit_hungry, sawit_angry];

function App() {
  const [index, setIndex] = useState(0);
  const [isExiting, setIsExiting] = useState(false);
  const [animateClass, setAnimateClass] = useState("animate__bounceIn");

  const handleClick = () => {
    if (isExiting) return;
    setIsExiting(true);
    setAnimateClass("animate__bounceOut");
  };

  const handleAnimationEnd = () => {
    if (isExiting) {
      setIndex((prevIndex) => {
        let nextIndex;
        do {
          nextIndex = Math.floor(Math.random() * images.length);
        } while (nextIndex === prevIndex);
        return nextIndex;
      });
      setIsExiting(false);
      setAnimateClass("animate__bounceIn");
    }
  };

  return (
    <main className={'flex flex-col justify-center items-center w-full h-svh p-10 gap-10'}>
      <div className={"flex flex-col justify-center items-center w-full animate__animated animate__pulse animate__infinite"}>
        <img
          src={images[index]}
          alt="Sawit"
          onClick={handleClick}
          onAnimationEnd={handleAnimationEnd}
          className={`relative object-contain animate__animated ${animateClass}`}
          style={{cursor: 'pointer'}}
        />
      </div>
      <div className={"text-center text-sm opacity-50 animate__animated animate__pulse animate__infinite"}>
        Click on the image to change it.
      </div>
    </main>
  )
}

export default App;
