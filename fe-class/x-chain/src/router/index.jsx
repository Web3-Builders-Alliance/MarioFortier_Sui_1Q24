import { createBrowserRouter } from 'react-router-dom'

import Layout from "../pages/layout";

import Home from "../pages/home";
import Explore from "../pages/explore";
import Pages from "../pages/pages";
import Community from "../pages/community";
import Contact from "../pages/contact";
import Collection from "../pages/collection";

import { rootLoader } from "./loaders/root";
import { homeLoader } from "./loaders/home";
import { exploreLoader } from "./loaders/explore";
import { communityLoader } from "./loaders/community";
import { aboutLoader } from "./loaders/about";
import { collectionLoader } from './loaders/collection';

export const ROUTES = ["Home", "Explore", "Pages", "Community", "Contact"];

export const router = createBrowserRouter([
  {
    element: <Layout />,
    // errorElement: <div>Oops this is an error</div>,
    loader: rootLoader,
    children: [
      {
        path: "/",
        element: <Home />,
        loader: homeLoader,
      },
      {
        path: "/explore",
        element: <Explore />,
        loader: exploreLoader,
      },
      {
        path: "/pages",
        element: <Pages />,
        leader: aboutLoader,
      },
      {
        path: "/community",
        element: <Community />,
        loader: communityLoader,
      },
      {
        path: "/contact",
        element: <Contact />,
        leader: aboutLoader,
      },
      {
        path: "*",
        element: <Home />,
      },
      {
        path: "/collection",
        element: <Collection />,
        loader: collectionLoader,
      },
    ],
  },
]);
