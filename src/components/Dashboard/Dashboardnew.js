"use client"
import { useState } from 'react'
import ReactGridLayout from 'react-grid-layout'
import 'react-grid-layout/css/styles.css'
import 'react-resizable/css/styles.css'
import './Dashboardnew.css'
import Counter from '../Modules/Counter'

export default function Dashboard() {
  const [layout, setLayout] = useState([
    {i: 'test1', x:0, y:0, w:2, h:1}
  ])
  const [modules, setModules] = useState({
    test1: 'counter'
  })

  return (
    <div className="dashboard-new">
      <ReactGridLayout
        className="layout"
        layout={layout}
        cols={12}
        rowHeight={30}
        width={1200}
        margin={[0, 0]}
      >
        {layout.map(item => (
          <div key={item.i} style={{ height: '100%'}}>
            <Counter id={item.i} onRemove={() => {}} />
          </div>
        ))}
      </ReactGridLayout>
    </div>
  )
}