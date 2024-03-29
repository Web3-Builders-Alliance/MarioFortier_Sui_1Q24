import React from 'react'
import ReactDOM from 'react-dom/client'

import { RouterProvider } from 'react-router-dom'
import { router } from './router'
import { WalletProvider } from "@suiet/wallet-kit";

ReactDOM.createRoot(document.getElementById('root')).render(  
  <React.StrictMode>
    <WalletProvider>
      <RouterProvider router={router} />
    </WalletProvider>
  </React.StrictMode>,
)
