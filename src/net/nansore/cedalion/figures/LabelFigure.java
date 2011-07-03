/*
 * Created on Jan 19, 2006
 */
package net.nansore.cedalion.figures;

import net.nansore.cedalion.eclipse.TermContext;
import net.nansore.cedalion.eclipse.TermVisualizationException;
import net.nansore.prolog.Compound;

import org.eclipse.draw2d.Label;

/**
 * A figure that displays a constant label, using the font it takes from its environment.
 * Takes one argument: the text to be displayed.
 */
public class LabelFigure extends Label implements TermFigure {

	public static int debugCount = 0;
	
    public LabelFigure(Compound term, TermContext context) throws TermVisualizationException {
        setForegroundColor(context.getColor());
        setFont(context.getFont(TermContext.NORMAL_FONT));
        setText(translateString(term));
        context.bindFigure(this);
        debugCount++;
    }

	private String translateString(Compound term) throws TermVisualizationException {
		try {
			return term.arg(1).toString();			
		} catch(ClassCastException e) {
			throw new TermVisualizationException("LabelFigure received non string: " + term.arg(1));
		}
	}

    /* (non-Javadoc)
     * @see net.nansore.visualterm.figures.TermFigure#updateFigure()
     */
    public void updateFigure() throws TermVisualizationException {
    }

    /* (non-Javadoc)
     * @see net.nansore.visualterm.figures.TermFigure#dispose()
     */
    public void dispose() {
    	erase();
    	debugCount--;
    }
    
    
}
