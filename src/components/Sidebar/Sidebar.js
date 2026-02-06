"use client";

import ModuleItem from "./ModuleItem";

export default function Sidebar() {
  return (
    <div className="sidebar">
        <ModuleItem moduleId="score" label="Score" icon="/icons/score.svg" />
        <ModuleItem moduleId="commandPoints" label="Command Points" icon="/icons/command-points.svg" />
        <ModuleItem moduleId="turnOrder" label="Turn Order" icon="/icons/turn-order.svg" />
        <ModuleItem moduleId="dice" label="Dice" icon="/icons/dice.svg" />
        <ModuleItem moduleId="counter" label="Counter" icon="/icons/counter.svg" />
    </div>
  );
}
