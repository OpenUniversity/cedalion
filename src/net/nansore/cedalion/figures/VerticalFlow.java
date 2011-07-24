/*
 * Created on Jan 20, 2006
 */
package net.nansore.cedalion.figures;

import net.nansore.cedalion.eclipse.TermContext;
import net.nansore.cedalion.eclipse.TermVisualizationException;
import net.nansore.cedalion.execution.TermInstantiationException;
import net.nansore.prolog.Compound;
import net.nansore.prolog.PrologException;

import org.eclipse.draw2d.FlowLayout;

/**
 * A FlowFigure that lays out its contents vertically.  Takes no extra arguments.
 */
public class VerticalFlow extends FlowFigure {

    /**
     * @param term
     * @param context
     * @throws TermVisualizationException
     * @throws PrologException 
     * @throws TermInstantiationException 
     */
    public VerticalFlow(Compound term, TermContext context) throws TermVisualizationException, TermInstantiationException, PrologException {
        super(term, context);
        // TODO Auto-generated constructor stub
    }
    
    protected void setLayout(Compound term) {
        setLayoutManager(new FlowLayout(false));
    }

}
