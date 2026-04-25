import { Routes } from '@angular/router';
import { OrdiniComponent } from './pages/ordini/ordini';
import { MenuComponent } from './pages/menu/menu';

export const routes: Routes = [
  { path: '', redirectTo: 'ordini', pathMatch: 'full' },
  { path: 'ordini', component: OrdiniComponent },
  { path: 'menu', component: MenuComponent },
];
