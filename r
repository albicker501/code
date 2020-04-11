// User.cpp : header file
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "user.h"
#include "graphics\graphicfunctions.h"
#include <iostream>
#include <fstream>
#include<string>
#include <sstream>
#ifndef _USE_OLD_OSTREAMS
using namespace std;
#endif

#include "math.h"
#include"string.h"
#include"time.h"
#define playerKI 2
#define player_human 1
#define dopple 1000
#define tripple 10000
#define quad 10000000
const int x_max = 1400;
const int y_max = 800;
const int feldsize = y_max / 10;
const int distance_Row_button = feldsize / 4;
const int Mark = (feldsize * 8) / 10;
const int row_h = (feldsize * 3) / 4;
const int row_b = (feldsize * 3) / 4;
const int maxdif = 10;
const int bouton_h = feldsize;
const int bouton_b = feldsize * 2;
const int row_x_tol = row_b / 2;
const int row_y_tol = row_h / 2;
const int high = 600; 
const int deep = x_max - 8 * feldsize;
const int space = feldsize / 2;
const int con_x_tol = bouton_b / 2;
const int con_y_tol = bouton_h / 2;


class Input {
public:
	int button_handler();
	void comandoin();
	int row_x_pos[7];
	int row_y_pos;
	int reset_x_pos;
	int reset_y_pos;
	int dif_plus_x_pos;
	int dif_plus_y_pos;
	int dif_minus_x_pos;
	int dif_minus_y_pos;
	std::string name;
	std::string daten;
	std::string befehl;
	std::ifstream datei;

}Button;

class Output
{
public:
	void Comadout(int mode);
	void printeff();
	void printmark(int spalte, int zeile, int size);
	void printwin();
	void feldmark();
	std::string savelog;

private:
	int Text_pos_x = 0;
	int Text_pos_y = 0;

}Log;

class Field
{
public:
	void main_reset();
	void feldprint();
	int mainfeld[7][6];
	int x_mainfeldpos[7];
	int y_mainfeldpos[6];
	int winpos_y[4];
	int winpos_x[4];
	int difficluty = 5;
	int player = player_human;
	int spalte_set;
	int zeile_set;
	int wichplayer = 0;
}Playfiled;

class Auswertung {
public:
	int points(int mode);
	int spaltepos(int spalte);
	int feldcount();
	int feldcountbegin();
private:
	const int value[5][5] = { {0,0,dopple,tripple,quad},
							  {0,0,0,0,0},
							  {-dopple,0,0,0,0},
							  {-tripple,0,0,0,0},
							  {-quad,0,0,0,0}, };
}Reward;

class Ki {
public:
	int minmax(int deep, int maxplayer, int alpha, int beta);
	void effizens();
	int eff[7][2];
	unsigned long timelast = 0;
	unsigned long timnow = 0;
	int solver = 1;
} KIplay;

int Input::button_handler()
{
	int x = 0;
	int y = 0;
	int klick = 0;
	int ok = 0;
	int value = 0;
	int x_pos = 0;
	while (1)
	{
		do
		{
			klick = mouseclick(&x, &y);
			if (klick == MK_LBUTTON)
			{
				if ((y <= row_y_pos + row_y_tol) && (y >= row_y_pos - row_y_tol))
				{
					for (int i = 0; i < 7; i++)
					{
						if ((x <= row_x_pos[i] + row_x_tol) && (x >= row_x_pos[i] - row_x_tol))
						{
							ok = 1;
							value = i;
						}
					}
				}
				if ((y <= reset_y_pos + con_y_tol) && (y >= reset_y_pos - con_y_tol) && (x <= reset_x_pos + con_x_tol) && (x >= reset_x_pos - con_x_tol))
				{
					ok = 1;
					value = 7;
				}
				if ((y <= dif_plus_y_pos + con_y_tol) && (y >= dif_plus_y_pos - con_y_tol) && (x <= dif_plus_x_pos + con_x_tol) && (x >= dif_plus_x_pos - con_x_tol))
				{
					ok = 1;
					value = 8;
				}
				if ((y <= dif_minus_y_pos + con_y_tol) && (y >= dif_minus_y_pos - con_y_tol) && (x <= dif_minus_x_pos + con_x_tol) && (x >= dif_minus_x_pos - con_x_tol))
				{
					ok = 1;
					value = 9;
				}
			}

		} while (ok == 0);

		if (value < 7 && value >= 0)
		{
			x_pos = Reward.spaltepos(value);
			if (x_pos < 6)
			{
				Playfiled.mainfeld[value][x_pos] = player_human;
				Log.printmark(value, x_pos, Mark);
				updatescr();
				Playfiled.spalte_set = value;
				Playfiled.zeile_set = x_pos;
				Playfiled.wichplayer = player_human;
				Log.Comadout(1);
				return 1;
			}
		}
		if (value == 7)
		{
			Playfiled.main_reset();
			updatescr();
			KIplay.timelast = 0;
			KIplay.timnow = 0;
			Log.printeff();
			return -1;
		}
		if (value == 8)
		{
			
			if (Playfiled.difficluty < maxdif)
			{
				Playfiled.difficluty++;
				textbox(Playfiled.x_mainfeldpos[0] - feldsize / 2 - 1, 0, Playfiled.x_mainfeldpos[6] + feldsize / 2 + 1, Playfiled.y_mainfeldpos[5] - feldsize / 2 - distance_Row_button, (feldsize * 3) / 5, BLACK, WHITE, WHITE, CENTER_ALIGN, "Difficulty:%d", Playfiled.difficluty);
				updatescr();
			}
			
		}
		if (value == 9)
		{
			
				if (Playfiled.difficluty > 1)
				{
					Playfiled.difficluty--;
					textbox(Playfiled.x_mainfeldpos[0] - feldsize / 2 - 1, 0, Playfiled.x_mainfeldpos[6] + feldsize / 2 + 1, Playfiled.y_mainfeldpos[5] - feldsize / 2 - distance_Row_button, (feldsize * 3) / 5, BLACK, WHITE, WHITE, CENTER_ALIGN, "Difficulty:%d", Playfiled.difficluty);
					updatescr();
				}
			

		}
	}
}

void Input::comandoin()
{
	char input;
	int pos1 = 0;
	int pos2 = 0;
	int escape = 0;
	int posA = 0;
	int spalte;
	int rot = 0;
	int gelb = 0;
	int zeile = 0;
	int fehler = 0;
	int mode = 0;
	int count = 1;
	std::string serach;

	name.clear();
	befehl.clear();
	daten.clear();
	std::cout << "Dateieinlesen(Y/N)" << endl;
	do
	{
		std::cin >> input;
	} while (input != 'Y' && input != 'N');
	if (input == 'Y')
	{
		do
		{
			printf("insert file name:");
			std::cin >> name;
			name.append(".txt");
			datei.open(name);
			if (datei.is_open())
			{
				escape = 1;
			}
			else
			{
				std::cout << "Datei existiert nicht \n Abbrechen (Y/N): ";
				do
				{
					std::cin >> input;
				} while (input != 'Y' && input != 'N');
				if (input == 'Y')
					escape = 2;
			}

		} while (escape == 0);
		if (escape==1)
		{
			char data[2];
			data[1] = '\0';
			while (datei.eof() == 0)
			{
				data[0] = datei.get();
				daten.append(data);
			}

			std::cout << "Data eingelesen" << endl;
			getchar();
		}
	}
	else
		mode = 1;
	while (1)
	{
		stringstream s;
		s << count;
		serach.clear();
		serach.append("E");
		serach.append(s.str());
		fehler = 0;
		if (mode == 0)
			pos1 = daten.find(serach,pos1);
		else
			pos1 = daten.find(';');
		if (pos1 == string::npos)
		{
			if (mode == 0)
				std::cout << "Alle Befehle abarbeiten" << endl;
			do
			{
				std::cout << " Weitere Befehle einlesen(Y/N)" << endl;
				do
				{
					cin >> input;
				} while (input != 'N' && input != 'Y' && input != 'n' && input != 'y');
				if (input == 'N' || input == 'n')
					return;
				else
					mode = 1;
				std::cout << ":" << endl;
				std::cin >> befehl;
				pos2 = 0;
				fehler = 0;
				pos1 = befehl.find(';');
				if (pos1 == string::npos)
				{
					std::cout << "Kein Semikolon gefunden neu eingabe?(Y/N)" << endl;
					do
					{
						std::cin >> input;
					} while (input != 'N' && input != 'Y'&& input != 'n' && input != 'y');
					if (input == 'N'||input=='n')
						return;

				}
			} while (pos1 == string::npos);
		}
		if (mode == 0)
		{
			char* tempcopy = new char[serach.length()+9];
			daten.copy(tempcopy, pos1+serach.length()+9 , pos1);
			befehl = tempcopy;
		}
		posA = befehl.find("rot");
		if (posA == string::npos)
		{
			posA = befehl.find("gelb");
			if (posA == string::npos)
			{
				std::cout << "Farbe nicht korrekt Befehl überspringen (Y/N):" << endl;
				do
				{
					std::cin >> input;
				} while (input != 'N' && input != 'Y' && input != 'n' && input != 'y');
				fehler = 1;
				if (input == 'N' || input == 'n')
					return;
			}
			else
				gelb = 1;
		}
		else
			rot = 1;
		if (fehler == 0)
		{
			posA = befehl.find(',');
			spalte = 10;

			for (char i = 0; i < 7; i++)
			{
				if (befehl.at(posA + 1) == 'A' + i)
				{
					spalte = i;
					break;
				}
			}
			if (spalte == 10)
			{
				std::cout << "Diese Spalte existiert nicht Befehl überspringen(Y/N):" << endl;
				do
				{
					std::cin >> input;
				} while (input != 'N' && input != 'Y' && input != 'n' && input != 'y');
				fehler = 1;
				if (input == 'N' || input == 'n')
					return;
			}
			if (fehler == 0)
			{

				posA = befehl.find(',', posA+1);
				zeile = Reward.spaltepos(spalte);
				if (zeile + 1 == (befehl.at(posA + 1))-'0')
				{
					if (rot == 1)
						Playfiled.mainfeld[spalte][zeile] = player_human;
					if (gelb == 1)
						Playfiled.mainfeld[spalte][zeile] = playerKI;
				}
				else
				{
					std::cout << "Zeile nicht belegbar Befehl überspringen(Y/N)" << endl;
					do
					{
						std::cin >> input;
					} while (input != 'N' && input != 'Y' && input != 'n' && input != 'y');
					fehler = 1;
					if (input == 'N' || input == 'n')
						return;
				}
			}
		}
		count++;
	}
}

void Output::feldmark()
{
	int count = 0;
	for (int x = 0; x < 7; x++)
		for (int y = 0; y < 6; y++)
			if (Playfiled.mainfeld[x][y] != 0)
			{
				Playfiled.player = Playfiled.mainfeld[x][y];
				Log.printmark(x, y, Mark);
			}
	Playfiled.player = player_human;

}

void Output::Comadout(int mode)
{
	std::string name;
	std::ofstream datei;
	char input;
	if (mode == 1)
	{
		if (Playfiled.wichplayer == playerKI)
		{
			
			for (int i = 0; i < 7; i++)
			{
				stringstream s;
				char save[2];
				save[1] = '\0';
				save[0] = 'A' + i;
				printf("%c: %d:",'A'+i,KIplay.eff[i][0]);
				savelog.append(save);
				savelog.append(":");
				s << KIplay.eff[i][0];
				savelog.append(s.str());

				savelog.append(" ");
			}
			printf("\n");
			savelog.append("\n");
			savelog.append("Gelb,");
			printf("Gelb,");
		}
		if (Playfiled.wichplayer == player_human)
		{
			printf("Rot,");
			savelog.append("Rot,");
		}
		char save[2];
		save[0] = 'A' + Playfiled.spalte_set;
		save[1] = '\0';
		savelog.append(save);
		savelog.append(",");
		printf("%c,", save[0]);
		save[0] = '1' + Playfiled.zeile_set;
		savelog.append(save);
		savelog.append("\n");
		printf("%c\n", save[0]);
	}
	else
	{
		std::cout << "Spielverlauf speichern ? (Y/N) " << endl;
		do
		{
			std::cin >> input;
		} while (input != 'Y' && input != 'N');
		if (input == 'N')
			return;
		std::cout << "Dateiname(ohne.txt):"<< endl;
		std::cin >> name;
		name.append(".txt");
		datei.open(name);
		if (datei.is_open())
		{
			int c = savelog.length();
			char* data = new char[c];
			savelog.copy(data, savelog.length());
			datei.write(data, savelog.length());
			delete data;
			datei.close();
		}
		else
		{
			std::cout << "Fehler. Datei kann nicht geöffnet werden" << endl;
		}

	}
}

void Output::printeff()
{
	int x1 = Playfiled.x_mainfeldpos[6] + feldsize;
	int y1 = Playfiled.y_mainfeldpos[5] - feldsize / 2;
	int x2 = x_max;
	int y2 = Playfiled.y_mainfeldpos[0];
	textbox(x1, y1, x2, y2, (feldsize * 5) / 9, BLACK, WHITE, WHITE, LEFT_ALIGN, "Calculat Time: %dms\nA:%d\nB:%d\nC:%d\nD:%d\nE:%d\nF:%d\nG:%d", (int)(KIplay.timnow - KIplay.timelast), KIplay.eff[0][0], KIplay.eff[1][0], KIplay.eff[2][0], KIplay.eff[3][0], KIplay.eff[4][0], KIplay.eff[5][0], KIplay.eff[6][0]);

}

void Output::printmark(int spalte, int zeile, int size)
{
	int colur[3] = { WHITE, RED,YELLOW };
	int x1 = Playfiled.x_mainfeldpos[spalte] - size / 2;
	int x2 = Playfiled.x_mainfeldpos[spalte] + size / 2;
	int y1 = Playfiled.y_mainfeldpos[zeile] + size / 2;
	int y2 = Playfiled.y_mainfeldpos[zeile] - size / 2;
	ellipse(x1, y1, x2, y2, colur[0], colur[Playfiled.player]);
}

void Output::printwin()
{
	for (int i = 0; i < 4; i++)
		printmark(Playfiled.winpos_x[i], Playfiled.winpos_y[i], (Mark * 3) / 4);
}

void Field::feldprint()
{
	int x1 = 0;
	int x2 = 0;
	int y1 = 0;
	int y2 = 0;
	int x_links = feldsize / 2;
	int y_unten = 7 * feldsize;
	for (int i = 0; i < 7; i++)
	{
		Playfiled.x_mainfeldpos[i] = x_links + feldsize / 2 + 1 + i * (1 + feldsize);
	}
	for (int i = 0; i < 6; i++)
	{
		Playfiled.y_mainfeldpos[i] = y_unten - (feldsize / 2 + 1 + i * (1 + feldsize));
	}
	y1 = Playfiled.y_mainfeldpos[5] - 1 - feldsize / 2;
	y2 = Playfiled.y_mainfeldpos[0] + 1 + feldsize / 2;
	for (int i = 0; i < 8; i++)
	{
		if (i < 7)
		{
			x1 = Playfiled.x_mainfeldpos[i] - feldsize / 2 - 1;
		}
		else
		{
			x1 = Playfiled.x_mainfeldpos[6] + feldsize / 2 + 1;
		}
		line(x1, y1, x1, y2, BLACK);
		updatescr();
	}
	x1 = Playfiled.x_mainfeldpos[0] - feldsize / 2 - 1;
	x2 = Playfiled.x_mainfeldpos[6] + feldsize / 2 + 1;
	for (int i = 0; i < 7; i++)
	{
		if (i < 6)
		{
			y1 = Playfiled.y_mainfeldpos[i] - feldsize / 2 - 1;
		}
		else
		{
			y1 = Playfiled.y_mainfeldpos[0] + feldsize / 2 + 1;
		}
		line(x1, y1, x2, y1, BLACK);
	}

	Button.row_y_pos = Playfiled.y_mainfeldpos[0] + (1 + feldsize / 2 + distance_Row_button + row_h / 2);
	y1 = Button.row_y_pos - row_h / 2;
	y2 = Button.row_y_pos + row_h / 2;
	for (int i = 0; i < 7; i++)
	{
		Button.row_x_pos[i] = Playfiled.x_mainfeldpos[i];
		x1 = Button.row_x_pos[i] - row_b / 2;
		x2 = Button.row_x_pos[i] + row_b / 2;
		rectangle(x1, y1, x2, y2, GREY, GREY);
		textbox(x1, y1, x2, y2, feldsize - 5, BLACK, -1, GREY, 0x05, "%c", 'A' + i);
	}
	y1 = Button.row_y_pos + row_h / 2 + distance_Row_button;
	y2 = Button.row_y_pos + row_h / 2 + distance_Row_button + bouton_h;
	x1 = Playfiled.x_mainfeldpos[0] - 1 - feldsize / 2;
	x2 = x1 + bouton_b;
	rectangle(x1, y1, x2, y2, GREY, GREY);
	textbox(x1, y1, x2, y2, (feldsize * 3) / 5, BLACK, -1, GREY, 0x05, "Diffuclty -");
	Button.dif_minus_x_pos = x1 + bouton_b / 2;
	Button.dif_minus_y_pos = y1 + bouton_h / 2;
	x1 = Playfiled.x_mainfeldpos[3] - bouton_b / 2;
	x2 = x1 + bouton_b;
	rectangle(x1, y1, x2, y2, GREY, GREY);
	textbox(x1, y1, x2, y2, (feldsize * 3) / 5, BLACK, -1, GREY, 0x05, "Reset");
	Button.reset_x_pos = x1 + bouton_b / 2;
	Button.reset_y_pos = y1 + bouton_h / 2;
	x2 = Playfiled.x_mainfeldpos[6] + feldsize / 2 - 1;
	x1 = x2 - bouton_b;
	rectangle(x1, y1, x2, y2, GREY, GREY);
	textbox(x1, y1, x2, y2, (feldsize * 3) / 5, BLACK, -1, GREY, BOTTOM_ALIGN, "Diffuclty+");
	Button.dif_plus_x_pos = x1 + bouton_b / 2;
	Button.dif_plus_y_pos = y1 + bouton_h / 2;
	textbox(Playfiled.x_mainfeldpos[0] - feldsize / 2 - 1, 0, Playfiled.x_mainfeldpos[6] + feldsize / 2 + 1, Playfiled.y_mainfeldpos[5] - feldsize / 2 - distance_Row_button, (feldsize * 3) / 5, BLACK, WHITE, WHITE, CENTER_ALIGN, "Difficulty:%d", Playfiled.difficluty);

}

void Field::main_reset()
{
	clrscr();
	for (int i = 0; i < 7; i++)
	{
		Button.row_x_pos[i] = 0;
	}
	Button.row_y_pos = 0;
	Button.reset_x_pos = 0;
	Button.reset_y_pos = 0;
	Button.dif_plus_x_pos = 0;
	Button.dif_plus_y_pos = 0;
	Button.dif_minus_x_pos = 0;
	Button.dif_minus_y_pos = 0;
	Playfiled.difficluty = 1;
	KIplay.solver = 1;
	Playfiled.player = player_human;
	for(int x=0;x<7;x++)
		for (int y = 0; y < 6; y++)
		{
			Playfiled.mainfeld[x][y] = 0;
			Playfiled.x_mainfeldpos[x] = 0;
			Playfiled.y_mainfeldpos[y] = 0;
			KIplay.eff[x][0] = 0;
			KIplay.eff[x][1] = 0;
		}
	for (int x = 0; x < 4; x++)
	{
		Playfiled.winpos_x[x] = 0;
		Playfiled.winpos_y[x] = 0;
	}
	feldprint();
	Log.savelog.clear();
}

int Auswertung::feldcount()
{
	int count = 0;
	for (int x = 0; x < 7; x++)
		for (int y = 0; y < 6; y++)
			if (Playfiled.mainfeld[x][y] != 0)
				count++;
	return count;
}

int Auswertung::feldcountbegin()
{
	int countR = 0;
	int countG = 0;
	for (int x = 0; x < 7; x++)
		for (int y = 0; y < 6; y++)
		{
			if (Playfiled.mainfeld[x][y] == playerKI)
				countG++;
			if (Playfiled.mainfeld[x][y] == player_human)
				countR++;
		}
	if ((countR - countG) > 0)
		return playerKI;
	if ((countR - countG) < 0)
		return player_human;
	srand(clock());
	return rand() % 2 + 1;
				
}

int Auswertung::spaltepos(int spalte)
{
	if (spalte < 0 || spalte>6)
		return -1;
	int count = 0;
	for (int i = 0; i < 6; i++)
		if (Playfiled.mainfeld[spalte][i] != 0)
			count++;
	return count;
}

 int Auswertung::points(int mode)
 {
	 int count_G = 0;
	 int count_R = 0;
	 int Punkte = 0;
	 for (int y = 0; y < 3; y++)
	 {
		 for (int x = 0; x < 7; x++)
		 {
			 count_G = 0;
			 count_R = 0;
			 for (unsigned int i = 0; i < 4; i++)
			 {
				 if (Playfiled.mainfeld[x][y + i] == 1)
					 count_R++;
				 if (Playfiled.mainfeld[x][y + i] == 2)
					 count_G++;
				 Playfiled.winpos_x[i] = x;
				 Playfiled.winpos_y[i] = y+i;
			 }
			 Punkte += Reward.value[count_R][count_G];
			 if ((Reward.value[count_R][count_G] == -quad) || (Reward.value[count_R][count_G] == quad))
			 {
				 if (mode == 1)
					 return Reward.value[count_R][count_G] == quad ? playerKI : player_human;
			 }
			 
	
			 
		 }
	 }
	 for (int x = 0; x < 7; x++)
	 {
		 for (int y = 0; y < 4; y++)
		 {
			 count_G = 0;
			 count_R = 0;
			 for (int i = 0; i < 4; i++)
			 {
				 if (Playfiled.mainfeld[x+i][y] == 1)
					 count_R++;
				 if (Playfiled.mainfeld[x+i][y] == 2)
					 count_G++;
				 Playfiled.winpos_x[i] = x + i;
				 Playfiled.winpos_y[i] = y;
			 }

			 Punkte += Reward.value[count_R][count_G];
			 if ((Reward.value[count_R][count_G] == -quad) || (Reward.value[count_R][count_G] == quad))
			 {
				 if (mode == 1)
					 return Reward.value[count_R][count_G] == quad ? playerKI : player_human;
			 }
		}
	 }
	 for (int x = 0; x < 4; x++)
	 {
		 for (int y = 0; y < 3; y++)
		 {
			 count_R = 0;
			 count_G = 0;
			 for (int i = 0; i < 4; i++)
			 {
				 if (Playfiled.mainfeld[x+i][y + i] == 1)
					 count_R++;
				 if (Playfiled.mainfeld[x+i][y + i] == 2)
					 count_G++;
				 Playfiled.winpos_x[i] = x + i;
				 Playfiled.winpos_y[i] = y + i;
			 }
			 Punkte += Reward.value[count_R][count_G];
			 if ((Reward.value[count_R][count_G] == -quad )||(Reward.value[count_R][count_G] == quad))
			 {
				 if (mode == 1)
					 return Reward.value[count_R][count_G] == quad ? playerKI : player_human;
			 }
			
		 }
	 }
	 for (int x = 6; x > 2; x--)
	 {

		 for (int y = 0; y < 3; y++)
		 {
			 count_G = 0;
			 count_R = 0;
			 for (int i = 0; i < 4; i++)
			 {
				 if (Playfiled.mainfeld[x-i][y + i] == 1)
					 count_R++;
				 if (Playfiled.mainfeld[x-i][y + i] == 2)
					 count_G++;
				 Playfiled.winpos_x[i] = x - i;
				 Playfiled.winpos_y[i] = y + i;
			 }
			 Punkte += Reward.value[count_R][count_G];
			 if (Reward.value[count_R][count_G] == -quad || Reward.value[count_R][count_G] == quad)
			 {
				 if (mode == 1)
					 return Reward.value[count_R][count_G] == quad ? playerKI : player_human;
			 }
			
		 }
	 }
	 if (mode == 1)
		 return -1;
	return Punkte;
 }

 int Ki::minmax(int deep, int maxplayer, int alpha, int beta)
 {
	 int minevalue = 0;
	 int maxevalue = 0;
	 int evalue = 0;
	 int zeile = 0;
	 if (deep == 0)
		 return Reward.points(0);
	 if (Reward.feldcount() == 42)
		 return Reward.points(0);
	 if (Reward.points(1) > 0)
		 return Reward.points(0);
	 if (maxplayer == playerKI)
	 {
		 maxevalue = INT_MIN;
		 for (int i = 0; i < 7; i++)
		 {
			 zeile = Reward.spaltepos(i);
			 if (zeile < 6)
			 {
				 Playfiled.mainfeld[i][zeile] = playerKI;
				 evalue = minmax(deep - 1, player_human, alpha, beta);
				 Playfiled.mainfeld[i][zeile] = 0;
				 maxevalue = max(maxevalue, evalue);
				 alpha = max(alpha, evalue);
				 if (beta <= alpha)
					 return maxevalue;
			 }
		 }

		 return maxevalue;
	 }
	 else
	 {
		 minevalue = INT_MAX;
		 for (int i = 0; i < 7; i++)
		 {
			 zeile = Reward.spaltepos(i);
			 if (zeile < 6)
			 {
				 Playfiled.mainfeld[i][zeile] = player_human;
				 evalue = minmax(deep - 1, playerKI, alpha, beta);
				 Playfiled.mainfeld[i][zeile] = 0;
				 minevalue = min(minevalue, evalue);
				 beta = min(beta, evalue);
				 if (beta <= alpha)
					 return minevalue;
			 }
		 }
		 return minevalue;
	 }

 }

 void Ki::effizens()
 {	

	 int sortmatrix[7];
	 int spalten[7] = { 0,0,0,0,0,0,0 };
	 int sortdeep = 0;
	 int maxv = INT_MIN;
	 int spalte;
	 int zeile = 0;
	 KIplay.timelast = clock();
	 srand(clock());
	 for (int i = 0; i < 7; i++)
	 {
		 zeile = Reward.spaltepos(i);
		 if (zeile<6)
		 {
			 Playfiled.mainfeld[i][zeile] = playerKI;
			 KIplay.eff[i][0]=minmax(Playfiled.difficluty - 1, player_human ,INT_MIN, INT_MAX);
			 Playfiled.mainfeld[i][zeile] = 0;
			 KIplay.eff[i][1] = 1;
			 sortmatrix[sortdeep] = KIplay.eff[i][0];
			 sortdeep++;
		}
		 else
			KIplay.eff[i][1] = 0;
	 }
	 for (int i = 0; i < sortdeep; i++)
	 {
		 maxv = max(maxv, sortmatrix[i]);
	 }

	 for (int i = 0; i < 7; i++)
	 {
		 if (KIplay.eff[i][1] == 1)
			 if (KIplay.eff[i][0] == maxv)
			 {
				 spalte = i;
				 break;
			 }
	 }
	 zeile = Reward.spaltepos(spalte);
	 Log.printmark(spalte, zeile, Mark);
	 Playfiled.mainfeld[spalte][zeile] = playerKI;
	 KIplay.timnow = clock();
	 Playfiled.spalte_set = spalte;
	 Playfiled.zeile_set = zeile;
	 Playfiled.wichplayer = playerKI;
	 Log.Comadout(1);
 }

 void user_main()
 {
	 int winplayer = 0;
	 int endplay = 0;
	 int Resetpress=0;
	 int begin = 0;
	 set_drawarea(x_max, y_max);
	 Playfiled.main_reset();
	 KIplay.timelast = 0;
	 KIplay.timnow = 0;
	 Log.printeff();
	 while (1)
	 {
		Button.comandoin();
		begin = Reward.feldcountbegin();
		Log.feldmark();
		 while (1)
		 {
			 if (begin == player_human)
			 {
				 if (Reward.feldcount() == 0)
					 while (Button.button_handler() != 1);
				 else
					 endplay = Button.button_handler();
			 }
			 begin = player_human;
			 if (endplay == -1)
				 break;
			 winplayer = Reward.points(1);
			 if (winplayer != -1)
			 {
				 Playfiled.player = winplayer;
				 Log.printwin();
				 break;
			 }
			 if (Reward.feldcount() == 42)
				 break;
			 Playfiled.player = playerKI;
			 KIplay.effizens();
			 Log.printeff();
			 winplayer = Reward.points(1);
			 if (winplayer != -1)
			 {
				 Playfiled.player = winplayer;
				 Log.printwin();
				 break;
			 }
			 if (Reward.feldcount() == 42)
				 break;
			 Playfiled.player = player_human;
		 }
		 Playfiled.player = 0;
		 KIplay.timelast = 0;
		 KIplay.timnow = 0;
		 updatescr();
		 Log.Comadout(0);
		 if(endplay!=-1)
			while (Button.button_handler() != -1);
		 endplay = 0;
		 Playfiled.player = player_human;
	 }
 }

