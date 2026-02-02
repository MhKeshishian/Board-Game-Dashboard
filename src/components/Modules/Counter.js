"use client"
import { useState } from 'react'


export default function Counter({ id, onRemove}) {
const [count, setCount] = useState(0)

    return (
        <div style={{
            padding: '10px',
            background: '#f0f0f0',
            borderRadius: '8px',
            height: '100%',
            width: '100%',
            boxSizing: 'border-box',
            color: '#333'
        }}>
        <button
            onClick={() => onRemove(id)}
            style={{ float: 'right', background: 'red', color: 'white'}}>
                x
            </button>
            <h3>Counter</h3>
            <p>Count: {count}</p>
            <button onClick={() => setCount(count + 1)}>+</button>
            <button onClick={() => setCount(count - 1)}>-</button>
        </div> 
    )
}